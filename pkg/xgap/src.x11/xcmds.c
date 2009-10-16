/****************************************************************************
**
*W  xcmds.c                     XGAP Source                      Frank Celler
**
*H  @(#)$Id: xcmds.c,v 1.6 1999/03/11 17:25:04 gap Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
*/
#include    "utils.h"			/* utility functions 		   */

#include    "popdial.h"			/* popup dialogs 		   */
#include    "gapgraph.h"		/* gap graphic sheet               */
#include    "gaptext.h"			/* gap text sheet                  */
#include    "xgap.h"
#include    "pty.h"
#include    "selfile.h"

#include    "xcmds.h"

/****************************************************************************
**

*F  * * * * * * * * * * * * *  local variables  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  DialogOkCancel  . . . . . . . . . . . . . . . . .  Cancel/OK popup dialog
*/
static TypePopupDialog DialogOkCancel;


/****************************************************************************
**
*V  GapWindows	. . . . . . . . . . . . . . . . . . . list of all gap windows
*/
static TypeList GapWindows;


/****************************************************************************
**
*V  HugeFont  . . . . . . . . . . . . . . . . . . . huge font for text output
*/
static XFontStruct * HugeFont;


/****************************************************************************
**
*V  LargeFont . . . . . . . . . . . . . . . . . .  large font for text output
*/
static XFontStruct * LargeFont;


/****************************************************************************
**
*V  NormalFont  . . . . . . . . . . . . . . . . . normal font for text output
*/
XFontStruct * NormalFont;


/****************************************************************************
**
*V  PopupMenus  . . . . . . . . . . . . . . . . . . . list of all popup menus
*/
static TypeList PopupMenus;


/****************************************************************************
**
*V  RunCursor . . . . . . . . . . . . cursor used when GAP is accepting input
*/
static Cursor RunCursor;


/****************************************************************************
**
*V  SleepCursor . . . . . . . . .  cursor used when GAP isn't accepting input
*/
static Cursor SleepCursor;


/****************************************************************************
**
*V  SmallFont . . . . . . . . . . . . . . . . . .  small font for text output
*/
static XFontStruct * SmallFont;


/****************************************************************************
**
*V  TextSelectors . . . . . . . . . . . . . . . .  list of all text selectors
*/
static TypeList TextSelectors;


/****************************************************************************
**
*V  TinyFont  . . . . . . . . . . . . . . . . . . . tiny font for text output
*/
static XFontStruct * TinyFont;


/****************************************************************************
**

*F  * * * * * * * * * * * *  communication with GAP * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  AnswerGap( <format>, <arg1>, <arg2>, <arg3>, <arg4> ) . . . return answer
*/
#define ANSWER_GAP(a,b,c,d,e)  \
    AnswerGap( a, (Long)(b), (Long)(c), (Long)(d), (Long)(e) )

static Boolean AnswerGap (
    String       format,
    Long         a1,
    Long         a2,
    Long         a3,
    Long         a4 )
{
    Int          arg;
    Int          len;
    Int          m;
    Int          n;
    Long         args[4];
    String       ptr;
    String       qtr;
    String       str;
    String       wtr;
    Char         hdr[14];

    /* give debug information */
    DEBUG( D_COMM, ( "AnswerGap( \"%s\", ... )\n", format ) );

    /* compute length of return string */
    args[0] = a1;  args[1] = a2;  args[2] = a3;  args[3] = a4;
    len = 12;
    arg = 0;
    for ( ptr = format;  *ptr;  ptr++ )
    {
	if ( arg == 4 )
	    return False;
	switch ( *ptr )
	{
	    case 'O':
	    case 'o':  len += 9;  break;
	    case 'E':
	    case 'e':  len += 9;  break;
	    case 'D':
	    case 'd':  len += 9;  arg++;  break;
	    case 'S':
	    case 's':  len += 9 + strlen((String)args[arg++]);  break;
	    default :  return False;
	}
    }

    /* allocate a string of length <len> */
    str = XtMalloc(len);

    /* parse arguments again */
    arg = 0;
    qtr = str;
    for ( ptr = format;  *ptr;  ptr++ )
    {
	switch ( *ptr )
	{
	    case 'O':
	    case 'o':
	        strcpy( qtr, "I0+" );
		qtr += 3;
		break;
	    case 'E':
	    case 'e':
		strcpy( qtr, "I1+" );
		qtr += 3;
		break;
	    case 'D':
	    case 'd':
		*qtr++ = 'I';
		n = (Int)args[arg++];
		for ( m = ( 0 < n ) ? n : -n;  0 < m;  m /= 10 )
		    *qtr++ = '0' + (m%10);
		if ( n < 0 )
		    *qtr++ = '-';
		else
		    *qtr++ = '+';
		break;
	    case 'S':
	    case 's':
		*qtr++ = 'S';
		wtr = (String)(args[arg++]);
		for ( m = strlen(wtr);  0 < m;  m /= 10 )
		    *qtr++ = '0' + (m%10);
		*qtr++ = '+';
		while ( *wtr )
		    *qtr++ = *wtr++;
		break;
	}
    }
    *qtr = '\0';

    /* write header */
    hdr[0] = '@';
    hdr[1] = 'a';
    qtr = hdr+2;
    for ( m = strlen(str);  0 < m;  m/= 10 ) {
	*qtr++ = '0' + (m%10);
    }
    *qtr++ = '+';
    *qtr = '\0';
    WriteGap( hdr, strlen(hdr) );

    /* write result back to gap process */
    WriteGap( str, strlen(str) );
    XtFree(str);
    return True;
}


/****************************************************************************
**
*F  ParseInt( <buf>, <val> )	. . . . . . . . . . . . . . . get a int value
*/
static Boolean ParseInt (
    String    * buf,
    Int       * val )
{
    Int         mult;

    if ( *(*buf)++ != 'I' )
	return False;
    *val = 0;
    mult = 1;
    do
    {
	if ( **buf == '+' )
	{
	    (*buf)++;
	    return True;
	}
	else if ( **buf == '-' )
	{
	    (*buf)++;
	    *val = -*val;
	    return True;
	}
	else if ( '0' <= **buf && **buf <= '9' )
	    *val += mult * (*((*buf)++)-'0');
	else
	    return False;
	mult = mult * 10;
    } while (1);
}


/****************************************************************************
**
*F  ParseString( <buf>, <str>, <len> )	. . . . . . . get a string from <ptr>
*/
static Boolean ParseString (
     String	  * buf,
     String       * str,
     Int          * len )
{
     Int            i;
     Int            m;
     String         ptr;

     if ( (*buf)[0] != 'S' )
         return False;
     ptr = (*buf)+1;
     for ( m=1,*len=0;  '0' <= *ptr && *ptr <= '9';  ptr++,m *= 10 )
	 *len += ( *ptr - '0' ) * m;
     *buf = ptr+1;
     *str = XtMalloc( (*len)+1 );
     for ( ptr = *str, i = *len;  0 < i;  i--, ptr++, (*buf)++ )
	 if ( **buf == '@' )
	 {
	     (*buf)++;
	     if ( **buf == '@' )
		 *ptr = **buf;
	     else
		 *ptr = (**buf) - 'A';
	 }
	 else
	     *ptr = **buf;
     *ptr = 0;
     return True;
}


/****************************************************************************
**
*F  GapWindowCmd( <cstr>, <len> ) . . . . . . . execute window command <cstr>
*/
extern TypeWindowCommand WindowCommands[];

Boolean GapWindowCmd (
    String              cstr,
    Int                 len )
{
    Boolean             ret;
    Int			ca;
    Int			ci;
    Int			cs;
    Int                 i;
    String              pa;
    String              str = cstr+3;
    TypeArg	        arg;
    TypeWindowCommand * cmd;
    char                name[4];

    /* give debug information */
    name[0] = cstr[0];  name[1] = cstr[1];  name[2] = cstr[2];  name[3] = 0;
    DEBUG( D_XCMD, ( "GapWindowCmd( \"%s\" )\n", name ) );

    /* try to find the command in <WindowCommands> */
    cmd = WindowCommands;
    while ( cmd->name )
	if ( !strncmp( cmd->name, name, 3 ) )
	    break;
	else
	    cmd++;
    if ( !cmd->name )
	return ANSWER_GAP( "esss", "unknown command '", name, "'", 0 );

    /* parse arguments */
    arg.opts = 0;
    ci = cs = 0;
    ca = 1;
    pa = cmd->args;
    while ( *pa )
    {
	if ( *pa == '*' )
	{
	    arg.opts = str;
	    break;
	}
	else if ( *pa == 'S' || *pa == 's' )
	{
	    if ( !ParseString( &str, &(arg.sargs[cs]), &len ) )
	    {
		ret = ANSWER_GAP("eds",ca,".th arg must be a string",0,0);
		goto free_strings;
	    }
	    else
		cs++;
	}
	else if ( *pa == '#' )
	{
	    if ( !ParseInt( &str, &i ) )
	    {
		ret = ANSWER_GAP("eds",ca,".th arg must be a window nr",0,0);
		goto free_strings;
	    }
	    arg.iargs[ci++] = i;
	    if ( LEN(GapWindows) <= arg.iargs[0] || arg.iargs[0] < 0 )
	    {
		ret = ANSWER_GAP( "es", "illegal window number", 0, 0, 0 );
		goto free_strings;
	    }
	    arg.win = (TypeGapWindow*)(ELM(GapWindows,arg.iargs[0]));
	    if ( ! arg.win->used )
	    {
		ret = ANSWER_GAP( "es", "window not used", 0, 0, 0 );
		goto free_strings;
	    }
	}
	else if ( *pa == 'T' )
	{
	    if ( !ParseInt( &str, &i ) )
	    {
		ret = ANSWER_GAP("eds",ca,".th arg must be a selector",0,0);
		goto free_strings;
	    }
	    arg.iargs[ci++] = i;
	    if ( LEN(TextSelectors) <= arg.iargs[0] || arg.iargs[0] < 0 )
	    {
		ret = ANSWER_GAP( "es", "illegal selector number", 0, 0, 0 );
		goto free_strings;
	    }
	    arg.sel = (TypeTextSelector*)(ELM(TextSelectors,arg.iargs[0]));
	    if ( arg.sel == 0)
	    {
		ret = ANSWER_GAP( "es", "selector not used", 0, 0, 0 );
		goto free_strings;
	    }
	}
	else if ( *pa == 'F' )
	{
	    if ( !ParseInt( &str, &i ) )
	    {
		ret = ANSWER_GAP("eds",ca,".th arg must be an integer",0,0);
		goto free_strings;
	    }
	    arg.iargs[ci++] = i;
	    switch ( (int)arg.iargs[ci-1] )
	    {
		case 1:  arg.font = TinyFont;   break;
		case 2:  arg.font = SmallFont;  break;
		case 3:  arg.font = NormalFont; break;
		case 4:  arg.font = LargeFont;  break;
		case 5:  arg.font = HugeFont;   break;
		default:
		    ret = ANSWER_GAP( "eds", ca,
				      ".th arg must be a font number", 0, 0 );
		    goto free_strings;
		    break;
	    }
	}
	else
	{
	    if ( !ParseInt( &str, &i ) )
	    {
		ret = ANSWER_GAP("eds",ca,".th arg must be an integer",0,0);
		goto free_strings;
	    }
	    arg.iargs[ci++] = i;
	}
	ca++;
	pa++;
    }
    if ( *pa != '*' && *str )
    {
	ret = ANSWER_GAP( "es", "too many arguments", 0, 0, 0 );
	goto free_strings;
    }


    /* call command */
    ret = cmd->func( &arg );

    /* free argument strings */
free_strings:
    for ( i = 0;  i < cs;  i++ )
	XtFree( arg.sargs[i] );
    return ret;
}


/****************************************************************************
**

*F  * * * * * * * * * * * functions for TextSelectors * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FunOpenSelector( <name>, <list>, <buttons> )  .  open a new text selector
*/
static void ButtonSelected (
    Widget	    w,
    XtPointer       cl,
    XtPointer       ca )
{
    Int             i = ((Int) ((Long)cl&0xffff)) % 256;
    Int             n = ((Int) ((Long)cl&0xffff)) / 256;
    char            buf[128];

    DEBUG( D_XCMD, ("ButtonSelected( #%ld, #%ld )\n", (long)n, (long)i) );
    sprintf( buf, "ButtonSelected(%ld,%ld);\n", (long)n, (long)i );
    SimulateInput(buf);
}

static void TextSelected (
    Widget	            w,
    XtPointer               cl,
    XtPointer               ca )
{
    XawListReturnStruct	  * ret = (XawListReturnStruct*) ca;
    Int                     n = (Int) ((Long)cl&0xffff);
    Int                     m = (Int) ret->list_index;
    char                    buf[128];

    DEBUG( D_XCMD, ("TextSelected( #%ld, $%ld )\n", (long)n, (long)m+1 ) );
    sprintf( buf, "TextSelected(%ld,%ld);\n", (long)n, (long)m+1 );
    SimulateInput(buf);
}

static void NotifyClick (
    Widget	    	  w,
    XEvent              * evt,
    String        	* str,
    Cardinal      	* n )
{
    XawListReturnStruct	  * ret;
    Int                     i;
    char                    buf[128];

    /* get currently selected */
    ret = XawListShowCurrent(w);

    /* if something is set,  return */
    if ( ret->list_index != XAW_LIST_NONE )
	return;

    /* find widget */
    for ( i = 0;  i < LEN(TextSelectors);  i++ )
	if ( ((TypeTextSelector*)ELM(TextSelectors,i))->list == w )
	{
	    sprintf( buf, "TextSelected(%ld,0);\n", (long)i );
	    SimulateInput(buf);
	    return;
	}
    
}

static char ButtonPressTrans[] =
    "<Btn1Down>,<Btn1Up>: Notify() NotifyClick()"; 

static Boolean FunOpenSelector (
    TypeArg           * arg )
{
    Int                 i;
    Int                 n;
    String              name = arg->sargs[0];
    String              ptr;
    String              qtr;
    TypeTextSelector  * selector;
    Widget              box;
    Widget              button;
    Widget              paned;
    Widget              viewport;
    char                buf[512];

    /* give debug info */
    DEBUG( D_XCMD, ( "OpenSelector( \"%s\", \"%s\", \"%s\" )\n",
	    arg->sargs[0], arg->sargs[1], arg->sargs[2] ) );

    /* create a new selector entry */
    selector = (TypeTextSelector*) XtMalloc( sizeof(TypeTextSelector) );

    /* create a new top level shell */
    selector->top = XtAppCreateShell(
		        "TextSelector", "XGap", topLevelShellWidgetClass,
			GapDisplay, 0, 0 );

    /* create a "paned" for the menu and text window */
    paned = XtVaCreateManagedWidget(
	        "textSelector", panedWidgetClass, selector->top, 0 );

    /* create a headline */
    XtVaCreateManagedWidget(
        "textSelectorTitle", labelWidgetClass, paned,
        XtNlabel, name, 0 );
				    

    /* create a viewport for the text selectors */
    viewport = XtVaCreateManagedWidget(
	           "textSelectorViewport", viewportWidgetClass, paned,
		   XtNallowHoriz,       False,
		   XtNallowVert,        True,
		   XtNuseBottom,        True,
		   XtNshowGrip,         False,
		   0 );

    /* compute number of entries */
    for ( i = 2, qtr = arg->sargs[1];  *qtr;  qtr++ )
	if ( *qtr == '|' )
	    i++;
    selector->text = (String*) XtMalloc(i*sizeof(String));

    /* parse text */
    for ( ptr = arg->sargs[1], i = 0;  *ptr;  i++ )
    {
    	qtr = buf;
    	while ( *ptr && *ptr != '|' )
    	    *qtr++ = *ptr++;
    	*qtr = 0;
    	if ( *ptr )  ptr++;
    	DEBUG( D_XCMD, ( "  entry = \"%s\"\n", buf ) );
	selector->text[i] = (String) XtMalloc(strlen(buf)+1);
	strcpy( selector->text[i], buf );
    }
    selector->text[i] = 0;

    /* find free entry in <TextSelectors> */
    for ( n = 0;  n < LEN(TextSelectors);  n++ )
	if ( ELM(TextSelectors,n) == 0 )
	    break;
    if ( n == LEN(TextSelectors) )
	AddList( TextSelectors, selector );
    else
	ELM(TextSelectors,n) = selector;
    
    /* create a list widget containing the text */
    selector->list = XtVaCreateManagedWidget(
		         "textSelectorList", listWidgetClass, viewport,
			 XtNlist,           selector->text,
			 XtNdefaultColumns, 1,
			 XtNforceColumns,   True,
			 0 );
    XtOverrideTranslations( selector->list, 
			    XtParseTranslationTable(ButtonPressTrans) );
    XtAddCallback( selector->list, XtNcallback, TextSelected,
		   (XtPointer)(n&0xffffL) );

    /* create a box containing the buttons */
    box = XtVaCreateManagedWidget(
	      "textSelectorBox", boxWidgetClass, paned,
	      XtNorientation,           XtorientHorizontal,
       	      XtNshowGrip,              False,
	      XtNskipAdjust,            True,
	      XtNresizeToPreferred, 	True,
	      0 );

    /* parse buttons */
    selector->buttons = List(0);
    for ( ptr = arg->sargs[2], i = 1;  *ptr;  i++ )
    {
    	qtr = buf;
    	while ( *ptr && *ptr != '|' )
    	    *qtr++ = *ptr++;
    	*qtr = 0;
    	if ( *ptr )  ptr++;
    	DEBUG( D_XCMD, ( "  button = \"%s\"\n", buf ) );
	button = XtVaCreateManagedWidget(
	             "textSelectorButton", commandWidgetClass, box,
	             XtNlabel,      buf,
	             XtNshapeStyle, XmuShapeOval,
	             0 );
	XtAddCallback(button,XtNcallback,ButtonSelected,
		      (XtPointer)((i+n*256)&0xffffL));
	AddList( selector->buttons, button );
    }


    /* realize the window and return the number */
    XtRealizeWidget(selector->top);

    /* add window to list and return window number */
    return ANSWER_GAP( "od", n, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunCloseSelector( <sel> ) . . . . . . . . . destroy an open text selector
*/
static Boolean FunCloseSelector (
    TypeArg   * arg )
{
    Int         i;

    /* give debug info */
    DEBUG( D_XCMD, ( "CloseSelector( #%ld )\n", (long)arg->iargs[0] ) );

    /* destroy top level shell (this will destroy all children) */
    XtDestroyWidget(arg->sel->top);

    /* clear text */
    for ( i = 0;  arg->sel->text[i];  i++ )
	XtFree( arg->sel->text[i] );
    XtFree( (char*) arg->sel->text );

    /* clear button list */
    XtFree( (char*) arg->sel->buttons->ptr );
    XtFree( (char*) arg->sel->buttons );

    /* clear entry in <TextSelectors> */
    ELM(TextSelectors,arg->iargs[0]) = 0;
    XtFree((char*)arg->sel);

    /* return OK */
    return AnswerGap( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunChangeList( <sel>, <buttons> )   . . . .  change list in text selector
*/
static Boolean FunChangeList (
    TypeArg       * arg )
{
    Int             i;
    String          ptr;
    String          qtr;
    String        * text;
    char            buf[512];

    /* give debug info */
    DEBUG( D_XCMD, ( "ChangeList( #%ld, \"%s\" )\n", (long)arg->iargs[0],
	   arg->sargs[0] ) );

    /* compute number of entries */
    for ( i = 2, qtr = arg->sargs[0];  *qtr;  qtr++ )
	if ( *qtr == '|' )
	    i++;
    text = (String*) XtMalloc(i*sizeof(String));

    /* parse text */
    for ( ptr = arg->sargs[0], i = 0;  *ptr;  i++ )
    {
    	qtr = buf;
    	while ( *ptr && *ptr != '|' )
    	    *qtr++ = *ptr++;
    	*qtr = 0;
    	if ( *ptr )  ptr++;
    	DEBUG( D_XCMD, ( "  entry = \"%s\"\n", buf ) );
	text[i] = (String) XtMalloc(strlen(buf)+1);
	strcpy( text[i], buf );
    }
    text[i] = 0;

    /* change list */
    XawListChange( arg->sel->list, text, 0, 0, True );

    /* clear old text */
    for ( i = 0;  arg->sel->text[i];  i++ )
	XtFree( arg->sel->text[i] );
    XtFree( (char*) arg->sel->text );
    arg->sel->text = text;

    /* return OK */
    return AnswerGap( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunEnableButton( <sel>, <but>, <enable> ) . . . . enable/disable a button
*/
static Boolean FunEnableButton (
    TypeArg   * arg )
{
    Int         i;
    Widget      entry;

    /* give debug info */
    DEBUG( D_XCMD, ( "EnableButton( #%ld, #%ld, #%ld )\n", 
           (long)arg->iargs[0], (long)arg->iargs[1], (long)arg->iargs[2] ) );

    /* check button number */
    i = arg->iargs[1]-1;
    if ( LEN(arg->sel->buttons) <= i || i < 0 )
	return ANSWER_GAP( "es", "illegal button number", 0, 0, 0 );
    entry = ELM(arg->sel->buttons,i);

    /* enable/disable */
    if ( arg->iargs[2] )
	XtVaSetValues( entry, XtNsensitive, True, 0 );
    else
	XtVaSetValues( entry, XtNsensitive, False, 0 );

    /* return OK */
    return AnswerGap( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunUnhighlihtSelector( <sel> )  . . . . . . . . . . ..  unhighlight entry
*/
static Boolean FunUnhighlihtSelector (
    TypeArg   * arg )
{
    /* give debug info */
    DEBUG( D_XCMD, ( "Unhighlight( #%ld )\n", (long)arg->iargs[0] ) );

    /* unhighlight entry */
    XawListUnhighlight(arg->sel->list);

    /* return OK */
    return AnswerGap( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**

*F  * * * * * * * * * * *  functions for PopupMenus * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FunPopupShell( <name>, <str> )  . . . . . . . . . .  create a popup shell
*/
static Int ChosenPane = 0;

static void PaneChosen (
    Widget	    w,
    XtPointer       cl,
    XtPointer       ca )
{
    TypePaneData  * pd = (TypePaneData*) cl;

    DEBUG( D_XCMD, ( "PaneChosen( #%ld, #%ld )\n", (long)pd->popup,
           (long)pd->pane ) );
    ChosenPane = pd->pane;
}

static void PopingDown (
    Widget	w,
    XtPointer   cl,
    XtPointer   ca )
{
    DEBUG( D_XCMD, ( "PopingDown\n" ) );
    ANSWER_GAP( "od", ChosenPane, 0, 0, 0 );
}

static char PopingDownTrans[] =
    "<BtnUp>: notify() MenuPopdown() unhighlight()"; 

static Boolean FunPopupShell (
    TypeArg       * arg )
{
    Int             i;
    String          ptr;
    String          qtr;
    TypeMenu      * menu;
    TypePaneData  * pd;
    Widget          pane;
    Widget          pshell;
    char	    buf[128];

    /* search for an identical popup shell */
    for ( i = 0;  i < LEN(PopupMenus);  i++ )
    {
	menu = ELM(PopupMenus,i);
	if (    ! strcmp( menu->name,   arg->sargs[0]  )
	     && ! strcmp( menu->string, arg->sargs[1]) )
	    break;
    }
    if ( i < LEN(PopupMenus) )
	return ANSWER_GAP( "od", i, 0, 0, 0 );

    /* create a shell */
    pshell = XtVaCreatePopupShell( "pshell", simpleMenuWidgetClass,
    	    	    	    	   XGap, XtNcursor, CursorTL, 0 );
    XtOverrideTranslations( pshell, 
			    XtParseTranslationTable(PopingDownTrans) );

    /* create headline */
    DEBUG( D_XCMD, ( "PopupShell( \"%s\", ... )\n", arg->sargs[0] ) );
    XtVaCreateManagedWidget( "menulabel", smeBSBObjectClass, pshell,
    	    	    	     XtNsensitive, False,
    	    	    	     XtNlabel,     arg->sargs[0],
    	    	    	     0 );
    XtVaCreateManagedWidget( "line", smeLineObjectClass, pshell, 0 );

    /* add popdown callback */
    XtAddCallback( pshell, XtNpopdownCallback, PopingDown, 0 );

    /* create menu entries */
    menu = (TypeMenu*) XtMalloc( sizeof(TypeMenu) );
    menu->shell   = pshell;
    menu->entries = List(0);
    menu->name    = XtMalloc(strlen(arg->sargs[0])+1);
    menu->string  = XtMalloc(strlen(arg->sargs[1])+1);
    strcpy( menu->name,   arg->sargs[0] );
    strcpy( menu->string, arg->sargs[1] );
    for ( ptr = arg->sargs[1], i = 1;  *ptr;  i++ )
    {
    	qtr = buf;
    	while ( *ptr && *ptr != '|' )
    	    *qtr++ = *ptr++;
    	*qtr = 0;
    	if ( *ptr )  ptr++;
    	DEBUG( D_XCMD, ( "  entry = \"%s\"\n", buf ) );
    	pane = XtVaCreateManagedWidget( "menupane", smeBSBObjectClass,
    	    	    	    	    	pshell, XtNlabel, buf, 0 );
    	pd = (TypePaneData*) XtMalloc( sizeof(TypePaneData) );
    	pd->pane   = i;
    	pd->popup  = LEN(PopupMenus);
    	pd->shell  = pshell;
    	XtAddCallback( pane, XtNcallback, PaneChosen, pd );
	AddList( menu->entries, (void*) pd );
    }

    /* add shell to popup shell list */
    AddList( PopupMenus, (void*) menu );
    return ANSWER_GAP( "od", LEN(PopupMenus)-1, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunShowPopup( <nr> )  . . . . . . . . . . . . . . . . popup a popup shell
*/
static Boolean FunShowPopup (
    TypeArg       * arg )
{
    Dimension       w1,  h1,  bw;
    Int        	    x,  y,  x2,  y2;
    Position        tmp;
    UInt            bt;
    Widget     	    popup;
    Window          child;
    Window          root;

    /* check popup number */
    if ( LEN(PopupMenus) <= arg->iargs[0] || arg->iargs[0] < 0 )
	return ANSWER_GAP("esd","illegal popup menu ",arg->iargs[0],0,0);
    popup = ((TypeMenu*)ELM(PopupMenus,arg->iargs[0]))->shell;

    /* get size of popup dialog */
    XtVaGetValues( popup,
                   XtNwidth,       &w1,
                   XtNheight,      &h1,
                   XtNborderWidth, &bw,
                   0,              0 );

    /* compute screen position */
    XQueryPointer( GapDisplay, MyRootWindow,
    	    	   &root, &child, &x, &y, &x2, &y2, &bt );
    tmp = DisplayWidth( GapDisplay, GapScreen );
    if ( x+w1 > tmp )
	x = tmp-w1;
    tmp = DisplayHeight( GapDisplay, GapScreen );
    if ( y+h1 > tmp )
	y = tmp-h1;

    /* popup the popup shell */
    XtVaSetValues( popup, XtNx, x-10, XtNy, y-10, 0 );
    XawSimpleMenuClearActiveEntry( popup );
    XtPopupSpringLoaded( popup );
    XtGrabPointer( popup, True, ButtonPressMask|ButtonReleaseMask,
		   GrabModeAsync, GrabModeAsync, None, None, CurrentTime );

    /* reset 'ChosenPane' */
    ChosenPane = 0;

    /* gap will be answered by 'PopingDown' */
    return True;
}


/****************************************************************************
**

*F  * * * * * * * * * * * * functions for Dialogs * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FunShowDialog( <nr>, <msg>, <def> )	. . . . . . . . . . show popup dialog
*/
static Boolean FunShowDialog (
    TypeArg       * arg )
{
    Int             first;
    Int             res;
    String          str;
#ifndef NO_FILE_SELECTOR
    static String   tmp = 0;
#endif

    /* OK/Cancel dialog */
    if ( arg->iargs[0] == 1 )
    {
	first  = 4;
	res    = PopupDialog( DialogOkCancel, arg->sargs[0],
			      arg->sargs[1], &str );
    }

    /* filename dialog */
    else if ( arg->iargs[0] == 2 )
    {
#       ifdef NO_FILE_SELECTOR
	  first  = 4;
	  res    = PopupDialog( DialogOkCancel, arg->sargs[0],
			        arg->sargs[1], &str );
#       else

	  /* free memory from the previous run */
	  if ( tmp ) {
	      XtFree(tmp);
              tmp = NULL;
          }

	  /* call the file selector */
	  if ( *(arg->sargs[1]) )
	      res = XsraSelFile(XGap,arg->sargs[0],arg->sargs[1],0,&str);
	  else
	      res = XsraSelFile(XGap,arg->sargs[0],0,0,&str);

	  /* ok is first button */
	  first = 1;
	  if ( res != first )
	      str = "";
          else
	      tmp = str;

#       endif
    }

    /* unkown dialog */
    else
	return ANSWER_GAP("esd","illegal popup dialog ",arg->iargs[0],0,0);

    /* return the result */
    return ANSWER_GAP( "ods", (res==first)?0:1, str, 0, 0 );
}


/****************************************************************************
**

*F  * * * * * * * * * * * * functions for Windows * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  CloseWindow( <win> )  . . . . . . . . . . . . . . .  close an open window
*/
static void CloseWindow (
    TypeGapWindow * win )
{
    Int             i;
    Int             j;
    TypeMenu      * menu;

    /* set <used> to false */
    win->used = False;

    /* free all menus */
    for ( i = 0;  i < LEN(win->menus);  i++ )
	if ( (menu=ELM(win->menus,i)) != 0 )
	{
	    for ( j = 0;  j < LEN(menu->entries);  j++ )
		XtFree((char*)ELM(menu->entries,j));
	    XtFree((char*)menu->entries->ptr);
	    XtFree((char*)menu->entries);
	    XtFree((char*)menu);
	}
    XtFree((char*)win->menus->ptr);
    XtFree((char*)win->menus);

    /* destroy top level shell (this will destroy all children) */
    XtDestroyWidget(win->top);
}
    

/****************************************************************************
**
*F  MouseClickWindow( <talk>, <cd>, <evt>, <ctd> )  . .  handle a mouse click
*/
static void MouseClickWindow (
    Widget 	    talk,
    XtPointer       cd,
    XEvent        * evt,
    Boolean       * ctd )
{
    Int             bn;
    TypeGapWindow * gap = ELM(GapWindows,(Int)((Long)cd&0xffff));
    char            buf[100];

    /* we only have a two button mouse */
    if ( evt->xbutton.button == Button1 )
        bn = 1;
    else if ( evt->xbutton.button == Button3 )
        bn = 2;
    else
	return;

    /* check boundaries */
    if ( gap->width <= evt->xbutton.x || gap->height <= evt->xbutton.y )
	return;

    /* give debug information */
    DEBUG( D_XCMD, ( "MouseClickWindow( %ld, %ld, %ld, %ld )\n", (long)cd,
	    (long)(evt->xbutton.x), (long)(evt->xbutton.y), (long)bn ) );

    /* construct gap command */
    sprintf( buf, "PointerButtonDown(%ld,%ld,%ld,%ld);\n", (long)cd,
	     (long)evt->xbutton.x, (long)evt->xbutton.y, (long)bn );
    SimulateInput(buf);
}


/****************************************************************************
**
*F  WmDeleteWindow( <w>, <event>, <pars>, <n> ) . . . . . . wm delete request
*/
static char * WmDeleteWindowTranslation =
    "<Message>WM_PROTOCOLS: WmDeleteWindow()\n";

static void WmDeleteWindow (
    Widget 	    w,
    XEvent        * event,
    String        * pars,
    Cardinal      * n )
{
    TypeGapWindow * win;
    Int             i;

    if ( event->type == ClientMessage
         && event->xclient.data.l[0] != WmDeleteWindowAtom )
	return;
    for ( i = 0;  i < LEN(GapWindows);  i++ )
    {
	win = (TypeGapWindow*)ELM(GapWindows,i);
	if ( win->used && win->top == w )
	    break;
    }
    if ( i < LEN(GapWindows) )
	CloseWindow(win);
}


/****************************************************************************
**
*F  FunOpenWindow( <name>, <width>, <height> )	. open a new window, external
*/
static Widget CreateTitleWindow (
    Widget	    paned )
{
    return XtVaCreateManagedWidget(
		       "xgapWindowText",
		       labelWidgetClass,     paned,
		       XtNlabel,             "GAP window",
 		       XtNskipAdjust,        True,
		       XtNshowGrip,          False,
		       0 );
}


static Boolean FunOpenWindow (
    TypeArg       * arg )
{
    Int             h = arg->iargs[1];
    Int             w = arg->iargs[0];
    Short           h1;
    Short           w1;
    String          name = arg->sargs[0];
    String          title;
    TypeGapWindow * window;
    Widget          button;
    Widget          paned;

    /* check arguments */
    if ( arg->iargs[0] < 1 || arg->iargs[1] < 1 )
	return ANSWER_GAP( "esdsd", "illegal window dimensions ",
			   arg->iargs[0], "x", arg->iargs[1] );
    /* give debug info */
    DEBUG( D_XCMD, ( "OpenWindow( \"%s\", %ld, %ld )\n", arg->sargs[0],
	   (long)arg->iargs[0], (long)arg->iargs[1] ) );

    /* setup a new window structure, this structure will live forever */
    window = (TypeGapWindow*) XtMalloc( sizeof(TypeGapWindow) );
    window->line_width = 0;
    window->color      = C_BLACK;
    window->menus      = List(0);
    window->used       = True;
    window->text       = 0;

    /* find title position */
    XtVaGetValues( GapTalk, XtNtitlePosition, &title, 0 );

    /* create a new top level shell */
    window->top = XtVaAppCreateShell(
		      "XGap", "GraphicSheet",
		      topLevelShellWidgetClass, GapDisplay,
		      0 );

    /* create a "paned" for the menu and text window */
    paned = XtVaCreateManagedWidget(
	        "xgapWindow", panedWidgetClass, window->top, 0 );

    /* add TOP tile */
    if ( *title == 'T' || *title == 't' )
	window->text = CreateTitleWindow(paned);

    /* create a menu box for the menu buttons */
    window->box = XtVaCreateManagedWidget(
		      "xgapWindowMenu", boxWidgetClass, paned,
 		      XtNskipAdjust,   		True,
		      XtNresizeToPreferred, 	True,
		      XtNshowGrip,     		False,
		      0 );

    /* create a dummy menu button */
    button = XtVaCreateManagedWidget( "dummy", commandWidgetClass,
				      window->box, XtNx, 0, 0 );

    /* add MIDDLE tile */
    if ( *title == 'M' || *title == 'm' )
	window->text = CreateTitleWindow(paned);

    /* create a viewport for the window */
    window->viewport = XtVaCreateManagedWidget(
		          "xgapWindowViewport",
			  viewportWidgetClass, paned,
			  XtNallowHoriz,       True,
			  XtNallowVert,        True,
			  XtNuseBottom,        True,
			  XtNshowGrip,         False,
                          XtNresizable,        True,
			  0 );

    /* create a drawable */
    window->draw = XtVaCreateManagedWidget(
	               "xgapWindowDrawable",
		       gapGraphicWidgetClass, window->viewport,
                       XtNwidth,              w,
	               XtNheight,             h,
		       0 );
    window->width  = w;
    window->height = h;

    /* fix dimensions of viewport */
    XtVaGetValues( window->viewport, XtNwidth, &w1, XtNheight, &h1, 0 );
    w1 = ( w1 < w ) ? w1 : w;
    h1 = ( h1 < h ) ? h1 : h;
    XtVaSetValues( window->viewport, XtNwidth, w1, XtNheight, h1, 0 );

    /* add BOTTOM tile */
    if ( window->text == 0 )
	window->text = CreateTitleWindow(paned);

    /* realize the window and return the number */
    XtRealizeWidget(window->top);

    /* add event handler for mouse clicks */
    XtAddEventHandler( window->draw, ButtonPressMask,
		       False, MouseClickWindow,
		       (XtPointer)(LEN(GapWindows)&0xffffL) );

    /* set handler for WM_DELETE_WINDOW */
    XSetWMProtocols(GapDisplay,XtWindow(window->top),&WmDeleteWindowAtom,1);
    XtOverrideTranslations(
	window->top, 
        XtParseTranslationTable(WmDeleteWindowTranslation) );

    /* remove dummy button and dummy text */
    XtDestroyWidget(button);
    XtVaSetValues( window->text, XtNlabel, name, 0 );

    /* define cursor */
    XDefineCursor( GapDisplay, XtWindow(window->top), SleepCursor );

    /* add window to list and return window number */
    AddList( GapWindows, (void*) window );
    return ANSWER_GAP( "od", LEN(GapWindows)-1, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunCloseWindow( <win> ) . . . . . . . . .  close an open window, external
*/
static Boolean FunCloseWindow (
    TypeArg   * arg )
{
    /* give debug info */
    DEBUG( D_XCMD, ( "CloseWindow( #%ld )\n", (long)arg->iargs[0] ) );

    /* close window */
    CloseWindow(arg->win);

    /* return OK */
    return AnswerGap( "o", 0, 0, 0, 0 );
}

/****************************************************************************
**
*F  FunAddTitle( <win>, <str> ) . . . . . . . . . . . . . . add a (sub) title
*/
static Boolean FunAddTitle (
    TypeArg   * arg )
{
    XtVaSetValues( arg->win->text, XtNlabel, arg->sargs[0], 0 );
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunColorModel() . . . . . . . color model used for gap graphics, external
*/
static Boolean FunColorModel (
    TypeArg   * arg )
{
    return ANSWER_GAP( "od", GCColorModel(GapDisplay), 0, 0, 0 );
}


/****************************************************************************
**
*F  FunFastUpdate( <win>, <flag> )  . . . . . . . . . en-/disable fast update
*/
static Boolean FunFastUpdate (
    TypeArg *	arg )
{
    Boolean	flag;

    flag = ( arg->iargs[1] == 0 ) ? False : True;
    if ( arg->win->fast_update != flag )
    {
	arg->win->fast_update = flag;
	GGFastUpdate( arg->win->draw, flag );
    }
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}



/****************************************************************************
**
*F  FunFontInfo( <win>, <fid> ) . . . . . . . . . .   information about fonts
*/
static Boolean FunFontInfo (
    TypeArg	* arg )
{
    XFontStruct * font = arg->font;

    return ANSWER_GAP( "oddd", font->ascent, font->descent,
		               font->max_bounds.width, 0 );
}


/****************************************************************************
**
*F  FunQueryPointer( <win> )  . . . . . . . . . . . . . . . . . query pointer
*/
static Boolean FunQueryPointer (
    TypeArg       * arg )
{
    Int        	    x,  y,  x2,  y2;
    UInt            bt;
    UInt            md;
    UInt            pt;
    Window          child;
    Window          root;

    /* query pointer */
    XQueryPointer( XtDisplay(arg->win->draw), XtWindow(arg->win->draw),
    	    	   &root, &child, &x, &y, &x2, &y2, &pt );

    /* and make a sanity check */
    if ( arg->win->width < x2 || x2 < 0 )
	x2 = -1;
    if ( arg->win->height < y2 || y2 < 0 )
	y2 = -1;

    /* check mouse buttons */
    bt = 0;
    if ( pt & Button1Mask )
	bt |= 1;
    if ( pt & Button3Mask )
	bt |= 2;

    /* check modifier keys */
    md = 0;
    if ( pt & ShiftMask )
	md |= 1;
    if ( pt & ControlMask )
	md |= 2;
    if ( pt & Mod1Mask )
	md |= 4;

    /* gap will be answered by 'PopingDown' */
    return ANSWER_GAP( "odddd", x2, y2, bt, md );
}


/****************************************************************************
**
*F  FunResize( <win>, <width>, <height> ) . . . . . . . . . . . resize window
*/
static Boolean FunResize (
    TypeArg * 		arg )
{
    ViewportWidget	viewport = (ViewportWidget)arg->win->viewport;
    Widget              dummy;

    /* check arguments */
    if ( arg->iargs[1] < 1 || arg->iargs[2] < 1 )
	return ANSWER_GAP( "esdsd", "illegal window dimensions ",
			   arg->iargs[1], "x", arg->iargs[2] );

    /* resize window */
    arg->win->width  = arg->iargs[1];
    arg->win->height = arg->iargs[2];
    GGResize( arg->win->draw, arg->iargs[1], arg->iargs[2] );

    /* try to update scrollbars */
    XtUnmanageChild(arg->win->draw);
    dummy = XtVaCreateManagedWidget(
	               "xgapWindowDrawable",
		       gapGraphicWidgetClass, (Widget)viewport,
                       XtNwidth,              arg->win->width,
	               XtNheight,             arg->win->height,
		       0 );
    XtUnmanageChild(dummy);
    XtManageChild(arg->win->draw);
    XtDestroyWidget(dummy);

    /* and return */
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**

*F  * * * * * * * * * * * * * functions for Menus * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FunMenu( <win>, <name>, <str> ) . . . . . . . . . . . create a menu entry
*/
static void MenuClick (
    Widget	    w,
    XtPointer       cl,
    XtPointer       ca )
{
    TypeMenuData  * pd = (TypeMenuData*) cl;
    char            buf[128];

    DEBUG( D_XCMD, ("MenuSelected( #%ld, #%ld, #%ld )\n", (long)pd->window,
	   (long)pd->popup, (long)pd->pane) );
    sprintf( buf, "MenuSelected( %ld, %ld, %ld );\n", (long)pd->window,
	     (long)pd->popup, (long)pd->pane );
    SimulateInput(buf);
}

static Boolean FunMenu (
    TypeArg       * arg )
{
    Int             i;
    String          ptr;
    String          qtr;
    TypeMenu      * menu;
    TypeMenuData  * pd;
    Widget          button;
    Widget          pane;
    Widget          pshell;
    char	    buf[128];

    /* create a menu button */
    DEBUG( D_XCMD, ( "Menu( \"%s\", ... )\n", arg->sargs[0] ) );
    button = XtVaCreateManagedWidget( "menuButton", menuButtonWidgetClass,
				      arg->win->box,
				      XtNlabel,      arg->sargs[0],
				      XtNshapeStyle, XmuShapeOval,
				      XtNleftBitmap, MenuSymbol,
				      0 );

    /* create a shell */
    pshell = XtVaCreatePopupShell( "menu", simpleMenuWidgetClass,
    	    	    	    	   button, XtNcursor, CursorTL, 0 );

    /* create menu entries */
    menu = (TypeMenu*) XtMalloc( sizeof(TypeMenu) );
    menu->button  = button;
    menu->shell   = pshell;
    menu->entries = List(0);
    for ( ptr = arg->sargs[1], i = 1;  *ptr; )
    {
    	qtr = buf;
    	while ( *ptr && *ptr != '|' )
    	    *qtr++ = *ptr++;
    	*qtr = 0;
    	if ( *ptr )  ptr++;
    	DEBUG( D_XCMD, ( "  entry = \"%s\"\n", buf ) );
	if ( *buf == '-' )
	    XtVaCreateManagedWidget( "line", smeLineObjectClass, pshell, 0 );
	else
	{
	    pane = XtVaCreateManagedWidget( buf, smeBSBObjectClass,
    	    	    	    	    	    pshell,
					    XtNlabel,       buf,
					    XtNrightMargin, 14,
                                            XtNrightBitmap, EmptyMarkSymbol,
	                                    0 );
	    pd = (TypeMenuData*) XtMalloc( sizeof(TypeMenuData) );
	    pd->window = arg->iargs[0];
	    pd->pane   = i;
	    pd->popup  = LEN(arg->win->menus);
	    pd->shell  = pane;
	    XtAddCallback( pane, XtNcallback, MenuClick, pd );
	    i++;
	    AddList( menu->entries, (void*) pd );
	}
    }

    /* add shell to popup shell list */
    AddList( arg->win->menus, (void*) menu );
    return ANSWER_GAP( "od", LEN(arg->win->menus)-1, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunDeleteMenu( <win>, <menu> )  . . . . . . . . . . . . . . delete a menu
*/
static Boolean FunDeleteMenu (
    TypeArg   * arg )
{
    TypeMenu  * menu;
    Int         j;

    /* check menu number */
    DEBUG( D_XCMD, ( "CheckMenuEntry( #%ld, #%ld, #%ld, %ld )\n",
	   (long)arg->iargs[0], (long)arg->iargs[1], (long)arg->iargs[2],
	   (long)arg->iargs[3] ) );
    if ( LEN(arg->win->menus) <= arg->iargs[1] || arg->iargs[1] < 0 )
	return ANSWER_GAP("esd","illegal menu number ",arg->iargs[1],0,0);
    menu = (TypeMenu*)ELM(arg->win->menus,arg->iargs[1]);
    if ( menu == 0 )
	return ANSWER_GAP( "esds", "menu ", arg->iargs[1],
 			   " is no longer used", 0 );

    /* delete this entry */
    ELM( arg->win->menus, arg->iargs[1] ) = 0;
    for ( j = 0;  j < LEN(menu->entries);  j++ )
	XtFree((char*)ELM(menu->entries,j));
    XtFree((char*)menu->entries->ptr);
    XtFree((char*)menu->entries);
    XtDestroyWidget(menu->button);
    XtFree((char*)menu);
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}    


/****************************************************************************
**
*F  FunCheckMenuEntry( <win>, <menu>, <entry>, <check> )  . .  add check mark
*/
static Boolean FunCheckMenuEntry (
    TypeArg   * arg )
{
    TypeMenu  * menu;
    Widget      entry;

    /* check menu number */
    DEBUG( D_XCMD, ( "CheckMenuEntry( #%ld, #%ld, #%ld, %ld )\n",
	   (long)arg->iargs[0], (long)arg->iargs[1], (long)arg->iargs[2],
	   (long)arg->iargs[3] ) );
    if ( LEN(arg->win->menus) <= arg->iargs[1] || arg->iargs[1] < 0 )
	return ANSWER_GAP("esd","illegal menu number ",arg->iargs[1],0,0);
    menu = (TypeMenu*)ELM(arg->win->menus,arg->iargs[1]);
    if ( menu == 0 )
	return ANSWER_GAP( "esds", "menu ", arg->iargs[1],
			   " is no longer used", 0 );

    /* check menu entry number */
    if ( LEN(menu->entries) < arg->iargs[2] || arg->iargs[2] <= 0 )
	return ANSWER_GAP("esd","illegal menu entry ",arg->iargs[2],0,0);
    entry = ((TypeMenuData*)ELM(menu->entries,arg->iargs[2]-1))->shell;

    /* set or clear check mark */
    if ( arg->iargs[3] )
	XtVaSetValues( entry, XtNrightBitmap, CheckMarkSymbol, 0 );
    else
	XtVaSetValues( entry, XtNrightBitmap, EmptyMarkSymbol, 0 );
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunEnableMenuEntry( <win>, <menu>, <entry>, <check> ) . .  enable/disable
*/
static Boolean FunEnableMenuEntry (
    TypeArg   * arg )
{
    TypeMenu  * menu;
    Widget      entry;

    /* check menu number */
    DEBUG( D_XCMD, ( "EnableMenuEntry( #%ld, #%ld, #%ld, %ld )\n",
	   (long)arg->iargs[0], (long)arg->iargs[1], (long)arg->iargs[2],
	   (long)arg->iargs[3] ) );
    if ( LEN(arg->win->menus) <= arg->iargs[1] || arg->iargs[1] < 0 )
	return ANSWER_GAP("esd","illegal menu number ",arg->iargs[1],0,0);
    menu = (TypeMenu*)ELM(arg->win->menus,arg->iargs[1]);
    if ( menu == 0 )
	return ANSWER_GAP( "esds", "menu ", arg->iargs[1],
			   " is no longer used", 0 );

    /* check menu entry number */
    if ( LEN(menu->entries) < arg->iargs[2] || arg->iargs[2] <= 0 )
	return ANSWER_GAP("esd","illegal menu entry ",arg->iargs[2],0,0);
    entry = ((TypeMenuData*)ELM(menu->entries,arg->iargs[2]-1))->shell;

    /* set or clear check mark */
    if ( arg->iargs[3] )
	XtVaSetValues( entry, XtNsensitive, True, 0 );
    else
	XtVaSetValues( entry, XtNsensitive, False, 0 );
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**

*F  * * * * * * * * * * * functions for GraphicObjects  * * * * * * * * * * *
*/


/****************************************************************************
**

*D  CHECK_BBOX( <obj> )	. . . . . . . . . .  check dimensions of bounding box
*/
#define	CHECK_BBOX(obj)	obj->x = ( obj->x < 0 ) ? 0 : obj-> x; \
                        obj->y = ( obj->y < 0 ) ? 0 : obj-> y


/****************************************************************************
**
*F  FunClearAll( <win> )  . . . . . . . . . . . . . . . . . clear all objects
*/
static Boolean FunClearAll (
    TypeArg   * arg )
{
    GGFreeAllObjects( arg->win->draw );
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunRemoveObjects( <win>, <obj>, ... )   . . . . .  remove a window object
*/
static Boolean FunRemoveObjects (
    TypeArg     * arg )
{
    String	  str;
    Int           n;

    /* return if no optional args are given */
    if ( (str=arg->opts) == 0 )
	return ANSWER_GAP( "es", "no objects given", 0, 0, 0 );

    /* give debug info */
    DEBUG( D_XCMD, ("RemoveObject( #%ld, %s )\n",(long)arg->iargs[0],str) );

    /* remove objects */
    if ( !arg->win->fast_update )
	GGStartRemove(arg->win->draw);
    while ( *str )
    {
	if ( !ParseInt( &str, &n ) )
	{
	    if ( !arg->win->fast_update )
		GGStopRemove(arg->win->draw);
	    return ANSWER_GAP( "es", "illegal argument", 0, 0, 0 );
	}
	if ( GGRemoveObject( arg->win->draw, n ) )
	{
	    if ( !arg->win->fast_update )
		GGStopRemove(arg->win->draw);
	    return ANSWER_GAP("esds","illegal object number: '",n,"'",0);
	}
    }
    if ( !arg->win->fast_update )
	GGStopRemove(arg->win->draw);
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunSetLineWidth( <win>, <wdt> ) . . . . . set line width for next objects
*/
static Boolean FunSetLineWidth (
    TypeArg   * arg )
{
    arg->win->line_width = ( arg->iargs[1] <= 1 ) ? 0 : arg->iargs[1];
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunSetColor( <win>, <col> ) . . . . . . . . .  set color for next objects
*/
static Boolean FunSetColor (
    TypeArg   * arg )
{
    if ( arg->iargs[1] < 0 )
	arg->win->color = C_BLACK;
    else if ( C_LAST < arg->iargs[1] )
	arg->win->color = C_BLACK;
    else
	arg->win->color = arg->iargs[1];
    return ANSWER_GAP( "o", 0, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunDrawBox( <win>, <x1>, <y1>, <x2>, <y2> ) . . . draw a filled rectangle
*/
static Boolean FunDrawBox (
    TypeArg               * arg )
{
    TypeGapGraphicObject  * obj;
    Int	                    n;

    /* create a line object */
    obj = (TypeGapGraphicObject*) XtMalloc( sizeof(TypeGapGraphicObject) );

    /* convert <x> and <y> coordinates to X windows style */
    obj->type  = T_BOX;
    obj->color = arg->win->color;
    obj->desc.rect.x1 = MIN( arg->iargs[1], arg->iargs[3] );
    obj->desc.rect.y1 = MIN( arg->iargs[2], arg->iargs[4] );
    obj->desc.rect.x2 = MAX( arg->iargs[1], arg->iargs[3] );
    obj->desc.rect.y2 = MAX( arg->iargs[2], arg->iargs[4] );
    obj->x = MIN( obj->desc.rect.x1, obj->desc.rect.x2 )-1;
    obj->y = MIN( obj->desc.rect.y1, obj->desc.rect.y2 )-1;
    obj->w = MAX( obj->desc.rect.x1, obj->desc.rect.x2 )+1;
    obj->h = MAX( obj->desc.rect.y1, obj->desc.rect.y2 )+1;
    CHECK_BBOX(obj);
    DEBUG( D_XCMD, ( "DrawBox( #%ld, %ld, %ld, %ld )\n",
	   (long)arg->iargs[0], (long)arg->iargs[1], 
	   (long)arg->iargs[2], (long)arg->iargs[3] ) );

    /* use 'GGAddObject' to draw the object */
    n = GGAddObject( arg->win->draw, obj );
    return ANSWER_GAP( "od", n, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunDrawCircle( <win>, <x>, <y>, <r> ) . . . . . . . . . . . draw a circle
*/
static Boolean FunDrawCircle (
    TypeArg               * arg )
{
    TypeGapGraphicObject  * obj;
    Int 	            n;
    Int                     w;

    /* create a circle object */
    obj = (TypeGapGraphicObject*) XtMalloc( sizeof(TypeGapGraphicObject) );

    /* convert <x> and <y> coordinates to X windows style */
    obj->type  = T_CIRCLE;
    obj->color = arg->win->color;
    obj->desc.circle.r = 2 * arg->iargs[3];
    obj->desc.circle.x = arg->iargs[1] - arg->iargs[3];
    obj->desc.circle.y = arg->iargs[2] - arg->iargs[3];
    w = obj->desc.circle.w  = arg->win->line_width;
    obj->x = obj->desc.circle.x - w - 1;
    obj->y = obj->desc.circle.y - w - 1;
    obj->w = obj->desc.circle.r+1 + 2*w + 2;
    obj->h = obj->desc.circle.r+1 + 2*w + 2;
    CHECK_BBOX(obj);
    DEBUG( D_XCMD, ( "DrawCircle( #%ld, %ld, %ld, %ld )\n",
	   (long)arg->iargs[0], (long)arg->iargs[1],
	   (long)arg->iargs[2], (long)arg->iargs[3] ) );

    /* use 'GGAddObject' to draw the object */
    n = GGAddObject( arg->win->draw, obj );
    return ANSWER_GAP( "od", n, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunDrawDisc( <win>, <x>, <y>, <r> ) . . . . . . . . . . draw a solid disc
*/
static Boolean FunDrawDisc (
    TypeArg               * arg )
{
    TypeGapGraphicObject  * obj;
    Int 	            n;

    /* create a disc object */
    obj = (TypeGapGraphicObject*) XtMalloc( sizeof(TypeGapGraphicObject) );

    /* convert <x> and <y> coordinates to X windows style */
    obj->type  = T_DISC;
    obj->color = arg->win->color;
    obj->desc.disc.r = 2 * arg->iargs[3];
    obj->desc.disc.x = arg->iargs[1] - arg->iargs[3];
    obj->desc.disc.y = arg->iargs[2] - arg->iargs[3];
    obj->x = obj->desc.disc.x;
    obj->y = obj->desc.disc.y;
    obj->w = obj->desc.disc.r+1;
    obj->h = obj->desc.disc.r+1;
    CHECK_BBOX(obj);
    DEBUG( D_XCMD, ( "DrawCircle( #%ld, %ld, %ld, %ld )\n",
	   (long)arg->iargs[0], (long)arg->iargs[1],
	   (long)arg->iargs[2], (long)arg->iargs[3] ) );

    /* use 'GGAddObject' to draw the object */
    n = GGAddObject( arg->win->draw, obj );
    return ANSWER_GAP( "od", n, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunDrawLine( <win>, <x1>, <y1>, <x2>, <y2> )  . . . . . . . . draw a line
*/
static Boolean FunDrawLine (
    TypeArg               * arg )
{
    TypeGapGraphicObject  * obj;
    Int 	            n;
    Int                     w;

    /* create a line object */
    obj = (TypeGapGraphicObject*) XtMalloc( sizeof(TypeGapGraphicObject) );
    obj->type  = T_LINE;
    obj->color = arg->win->color;
    obj->desc.line.x1 = arg->iargs[1];
    obj->desc.line.y1 = arg->iargs[2];
    obj->desc.line.x2 = arg->iargs[3];
    obj->desc.line.y2 = arg->iargs[4];
    w = obj->desc.line.w  = arg->win->line_width;
    obj->x = MIN( obj->desc.line.x1, obj->desc.line.x2 ) - w;
    obj->y = MIN( obj->desc.line.y1, obj->desc.line.y2 ) - w;
    obj->w = MAX( obj->desc.line.x1, obj->desc.line.x2 ) - obj->x + 1 + 2*w;
    obj->h = MAX( obj->desc.line.y1, obj->desc.line.y2 ) - obj->y + 1 + 2*w;
    CHECK_BBOX(obj);
    DEBUG( D_XCMD, ( "DrawLine( #%ld, %ld, %ld, %ld, %ld )\n",
	   (long)arg->iargs[0], (long)obj->desc.line.x1,
	   (long)obj->desc.line.y1, (long)obj->desc.line.x2,
	   (long)obj->desc.line.y2 ) );

    /* use 'GGAddObject' to draw the object */
    n = GGAddObject( arg->win->draw, obj );
    return ANSWER_GAP( "od", n, 0, 0, 0 );
}



/****************************************************************************
**
*F  FunDrawRectangle( <win>, <x1>, <y1>, <x2>, <y2> ) . . .  draw a rectangle
*/
static Boolean FunDrawRectangle (
    TypeArg               * arg )
{
    TypeGapGraphicObject  * obj;
    Int 	            n;
    Int                     w;

    /* create a line object */
    obj = (TypeGapGraphicObject*) XtMalloc( sizeof(TypeGapGraphicObject) );

    /* convert <x> and <y> coordinates to X windows style */
    obj->type  = T_RECT;
    obj->color = arg->win->color;
    obj->desc.rect.x1 = MIN( arg->iargs[1], arg->iargs[3] );
    obj->desc.rect.y1 = MIN( arg->iargs[2], arg->iargs[4] );
    obj->desc.rect.x2 = MAX( arg->iargs[1], arg->iargs[3] );
    obj->desc.rect.y2 = MAX( arg->iargs[2], arg->iargs[4] );
    w = obj->desc.rect.w  = arg->win->line_width;
    obj->x = MIN( obj->desc.rect.x1, obj->desc.rect.x2 ) - w;
    obj->y = MIN( obj->desc.rect.y1, obj->desc.rect.y2 ) - w;
    obj->w = MAX( obj->desc.rect.x1, obj->desc.rect.x2 ) - obj->x + 1 + 2*w;
    obj->h = MAX( obj->desc.rect.y1, obj->desc.rect.y2 ) - obj->y + 1 + 2*w;
    CHECK_BBOX(obj);
    DEBUG( D_XCMD, ( "DrawRectangle( #%ld, %ld, %ld, %ld )\n",
	   (long)arg->iargs[0], (long)arg->iargs[1],
	   (long)arg->iargs[2], (long)arg->iargs[3] ) );

    /* use 'GGAddObject' to draw the object */
    n = GGAddObject( arg->win->draw, obj );
    return ANSWER_GAP( "od", n, 0, 0, 0 );
}


/****************************************************************************
**
*F  FunDrawText( <win>, <fid>, <x>, <y>, <str> )  . . . . . . draw text <str>
*/
static Boolean FunDrawText (
    TypeArg               * arg )
{
    TypeGapGraphicObject  * obj;
    XFontStruct           * font = arg->font;
    Int  	            n;

    /* create a TEXT object */
    obj = (TypeGapGraphicObject*) XtMalloc( sizeof(TypeGapGraphicObject) );

    /* convert <x> and <y> coordinates to X windows style */
    obj->type  = T_TEXT;
    obj->color = arg->win->color;
    obj->desc.text.x    = arg->iargs[2];
    obj->desc.text.y    = arg->iargs[3];
    obj->desc.text.font = font->fid;
    obj->desc.text.len  = strlen(arg->sargs[0]);
    obj->desc.text.str  = XtMalloc(obj->desc.text.len+1);
    strcpy( obj->desc.text.str, arg->sargs[0] );
    obj->x = arg->iargs[2] - 1;
    obj->y = arg->iargs[3] - font->ascent - 1;
    obj->w = obj->desc.text.len*font->max_bounds.width + 2;
    obj->h = font->descent + font->ascent + 2;
    CHECK_BBOX(obj);
    DEBUG( D_XCMD, ( "DrawText( #%ld, %ld, %ld, %s )\n",
	   (long)arg->iargs[0], (long)arg->iargs[1],
	   (long)arg->iargs[2], arg->sargs[0] ) );

    /* use 'GGAddObject' to draw the object */
    n = GGAddObject( arg->win->draw, obj );
    return ANSWER_GAP( "od", n, 0, 0, 0 );
}


/****************************************************************************
**

*F  FunPlaybackFile( <filename> ) . . . . . . . . .  playback file <filename>
*/
static Boolean FunPlaybackFile (
    TypeArg               * arg )
{
    return PlaybackFile(arg->sargs[0]) ? 
        ANSWER_GAP( "o", 0, 0, 0, 0 ) 
      : ANSWER_GAP( "es", "cannot open file", 0, 0, 0 );
}


/****************************************************************************
**
*F  FunResumePlayback() . . . . . . . . . . . . . . . resume playback of file
*/
static Boolean FunResumePlayback (
    TypeArg               * arg )
{
    return ResumePlayback() ? 
        ANSWER_GAP( "o", 0, 0, 0, 0 ) 
      : ANSWER_GAP( "es", "no playback in progress", 0, 0, 0 );
}


/****************************************************************************
**

*F  * * * * * * * * * *  interface to the main program  * * * * * * * * * * *
*/


/****************************************************************************
**

*V  WindowCommands[]  . . . . . . . . . .  . . . . .  list of window commands
*/
TypeWindowCommand WindowCommands[] =
{
    { "XAT",    "#S",       FunAddTitle             },
    { "XCA",    "#",        FunClearAll             },
    { "XCL",    "TS",       FunChangeList           },
    { "XCM",    "#III",     FunCheckMenuEntry 	    },
    { "XCN",    "",         FunColorModel           },
    { "XCO",    "#I",       FunSetColor             },
    { "XCS",    "T",        FunCloseSelector        },
    { "XCW",    "#",        FunCloseWindow          },
    { "XDB",    "#IIII",    FunDrawBox              },
    { "XDC",    "#III",     FunDrawCircle           },
    { "XDD",    "#III",     FunDrawDisc             },
    { "XDL",    "#IIII",    FunDrawLine             },
    { "XDM",    "#I",       FunDeleteMenu           },
    { "XDR",    "#IIII",    FunDrawRectangle        },
    { "XDT",    "#FIIS",    FunDrawText             },
    { "XEB",    "TII",      FunEnableButton         },
    { "XEM",    "#III",     FunEnableMenuEntry 	    },
    { "XFI",    "F",        FunFontInfo             },
    { "XFU",    "#I",       FunFastUpdate           },
    { "XLW",    "#I",       FunSetLineWidth         },
    { "XME",    "#SS",      FunMenu                 },
    { "XOS",    "SSS",      FunOpenSelector         },
    { "XOW",  	"SII",      FunOpenWindow           },
    { "XPF",    "S",        FunPlaybackFile         },
    { "XPS",    "SS" ,      FunPopupShell           },
    { "XQP",    "#",        FunQueryPointer         },
    { "XRE",    "#II",      FunResize               },
    { "XRP",    "",         FunResumePlayback       },
    { "XRO",    "#*",       FunRemoveObjects        },
    { "XSD",    "ISS",      FunShowDialog           },
    { "XSP",    "I",        FunShowPopup            },
    { "XUS",    "T",        FunUnhighlihtSelector   },
    { 0L,       0L,         0L              	    }
};


/****************************************************************************
**
*V  PrivateActions  . . . . . . . . . . . . . . . . . . . .  action functions
*/
static XtActionsRec PrivateActions[] =
{
    { "NotifyClick",  	NotifyClick    },
    { "WmDeleteWindow", WmDeleteWindow }
};


/****************************************************************************
**
*F  InitXCMDS()	. . . . . . . . . . . . . . .  initalize all global variables
*/
void InitXCMDS ()
{

    /* get the fonts form the database for <GapTalk> */
    XtVaGetValues( GapTalk,
		   XtNtinyFont,     &TinyFont,
		   XtNsmallFont,    &SmallFont,
		   XtNnormalFont,   &NormalFont,
		   XtNlargeFont,    &LargeFont,
                   XtNhugeFont,     &HugeFont,
		   0 );

    /* create lists for windows, popups, and selectors */
    GapWindows    = List(0);
    PopupMenus    = List(0);
    TextSelectors = List(0);

    /* create cursors */
    SleepCursor = XCreateFontCursor( GapDisplay, XC_watch );
    RunCursor   = XCreateFontCursor( GapDisplay, XC_top_left_arrow );

    /* create popup dialogs */
    DialogOkCancel = CreatePopupDialog( AppContext, XGap, "OkCancelDialog",
				        PD_OK | PD_CANCEL, PD_OK, 0 );

    /* register private actions */
    XtAppAddActions( AppContext, PrivateActions, XtNumber(PrivateActions) );
}


/****************************************************************************
**
*F  UpdateXCMDS( <state> )  . . . . . . . . . .  gap is/isn't accepting input
*/
void UpdateXCMDS ( state )
    Boolean             state;
{
    TypeGapWindow *	win;
    Int                 i;

    /* GAP accepts input */
    if ( state )
    {
	for ( i = 0;  i < LEN(GapWindows);  i++ )
	{
	    win = ELM( GapWindows, i );
	    if ( win && win->used == True )
		XDefineCursor( GapDisplay, XtWindow(win->top), RunCursor );
	}
    }

    /* GAP doesn't accept input */
    else
    {
	for ( i = 0;  i < LEN(GapWindows);  i++ )
	{
	    win = ELM( GapWindows, i );
	    if ( win && win->used == True )
		XDefineCursor( GapDisplay, XtWindow(win->top), SleepCursor );
	}
    }
}


/****************************************************************************
**
*F  ExitXCMDS()	. . . . . . . . . . . . . . . . .  clear all global variables
*/
void ExitXCMDS ()
{
    TypeArg         arg;
    TypeMenu      * menu;
    Int             i;
    Int             j;

    /* clear list of windows and popups */
    for ( i = 0;  i < LEN(GapWindows);  i++ )
    {
	arg.win = ELM(GapWindows,i);
	if ( arg.win->used )
	    FunCloseWindow(&arg);
	XtFree((char*)ELM(GapWindows,i));
    }
    XtFree((char*)GapWindows);
    for ( i = 0;  i < LEN(TextSelectors);  i++ )
    {
	arg.sel = ELM(TextSelectors,i);
	if ( arg.sel != 0 )
	{
	    FunCloseSelector(&arg);
	    XtFree((char*)ELM(TextSelectors,i));
	}
    }
    XtFree((char*)TextSelectors);
    for (i = 0;  i < LEN(PopupMenus);  i++ )
	if ( (menu = ELM(PopupMenus,i)) != 0 )
	{
	    for ( j = 0;  j < LEN(menu->entries);  j++ )
		XtFree((char*)ELM(menu->entries,j));
	    XtFree((char*)menu->entries);
	    XtFree((char*)menu);
	}
    XtFree((char*)PopupMenus);
}


/****************************************************************************
**

*E  xcmds.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
