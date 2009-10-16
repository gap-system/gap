/****************************************************************************
**
*W  gaptext.c                 	XGAP source	                 Frank Celler
**
*H  @(#)$Id: gaptext.c,v 1.5 2000/11/22 15:41:17 gap Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
**
**  The GapTextWidget is  intended to be used as   a simple front  end to the
**  text widget with a gap  text source and an ascii  sink attached to it. It
**  is a subclass of the standard text widget  supplied with X11R4 and should
**  work with X11R5 and X11R6.
*/
#include    "utils.h"
#include    "gaptext.h"

extern void _XawTextPrepareToUpdate();
extern int  _XawTextReplace();
extern void _XawTextSetScrollBars();
extern void _XawTextCheckResize();
extern void _XawTextExecuteUpdate();


/****************************************************************************
**

*F  * * * * * * * * * * * * * * gap text widget * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  GapTextInsertSelection( <w>, <evt>, <parms>, <nums> ) . . . . insert text
**
**  DESCRIPTION
**    Handle  a  selection  insert event. 'GapTextInsertSelection' calls  the
**    input callback method with the selected string.
*/
#define CTR(a)	( a & 0x1f )

static void GetSelection ( Widget, Time, String *, Cardinal );

static void GapTextInsertSelection (
    Widget              w,
    XEvent            * evt,
    String            * parms,
    Cardinal          * nums )
{
    Time                time = 0;

    /* get the time of the event */
    if ( evt != NULL )
	switch ( evt->type )
	{
	    case ButtonPress:
	    case ButtonRelease:
	        time = evt->xbutton.time;
		break;
	    case KeyPress:
	    case KeyRelease:
		time = evt->xkey.time;
		break;
	    default:
		time = CurrentTime;
		break;
	}

    /* and insert the selection */
    GetSelection( w, time, parms, *nums );
}

struct _SelectionList
{
    String    * params;
    Cardinal    count;
    Time        time;
};

static void DoSelection (
    Widget              w,
    XtPointer           cd,
    Atom              * selection,
    Atom              * type,
    XtPointer           value,
    UInt              * length,
    Int               * format )
{
    GapTextWidget       gap = (GapTextWidget) w;
    char                buf[2];
    String              ptr;
    Boolean             nl;
    Int                 len;

    if ( *type == 0 || *length == 0 )
    {
	struct _SelectionList* list = (struct _SelectionList*)cd;

	if ( list != NULL )
	{
	    GetSelection( w, list->time, list->params, list->count );
	    XtFree(cd);
	}
	return;
    }

    /* check if string begins with gap prompt */
    ptr = (char*) value;
    len = *length;
    if ( gap->gap.drop_gap_prompt )
    {
	if ( 2 < len && ptr[0] == '>' && ptr[1] == ' ' )
	{
	    ptr += 2;
	    len -= 2;
	}
	else if ( 5 < len && !strncmp( ptr, "gap> ", 5 ) )
	{
	    ptr += 5;
	    len -= 5;
	}
	else if ( 5 < len && !strncmp( ptr, "brk> ", 5 ) )
	{
	    ptr += 5;
	    len -= 5;
	}
    }

    /* and call the callback */
    buf[0] = '@';
    for ( nl = False;  0 < len;  len--, ptr++ )
    {
	if ( nl && gap->gap.drop_gap_prompt )
	{
	    if ( 2 < len && ptr[0] == '>' && ptr[1] == ' ' )
	    {
		ptr += 1;
		len -= 1;
		continue;
	    }
	    else if ( 5 < len && !strncmp( ptr, "gap> ", 5 ) )
	    {
		ptr += 4;
		len -= 4;
		continue;
	    }
	    else if ( 5 < len && !strncmp( ptr, "brk> ", 5 ) )
	    {
		ptr += 4;
		len -= 4;
	    }
	}
	if ( CTR('@') < *ptr && *ptr <= CTR('Z') )
	{
	    buf[1] = '@' + *ptr;
	    gap->gap.input_callback( buf, 2 );
	}
	else if ( *ptr == '@' )
	{
	    buf[1] = '@';
	    gap->gap.input_callback( buf, 2 );
	}
	else
	    gap->gap.input_callback( ptr, 1 );
	nl = *ptr == '\n' || *ptr == '\r';
    }
    XtFree(cd);
    XFree(value);
}

static void GetSelection (
    Widget 	    w,
    Time 	    time,
    String        * parms,
    Cardinal 	    nums )
{
    Atom            selection;
    Int             buffer;

    /* try to find which buffer <*parms> is pointing to */
    selection = XInternAtom( XtDisplay(w), *parms, False );
    switch (selection)
    {
      case XA_CUT_BUFFER0: buffer = 0;  break;
      case XA_CUT_BUFFER1: buffer = 1;  break;
      case XA_CUT_BUFFER2: buffer = 2;  break;
      case XA_CUT_BUFFER3: buffer = 3;  break;
      case XA_CUT_BUFFER4: buffer = 4;  break;
      case XA_CUT_BUFFER5: buffer = 5;  break;
      case XA_CUT_BUFFER6: buffer = 6;  break;
      case XA_CUT_BUFFER7: buffer = 7;  break;
      default:	           buffer = -1; break;
    }

    /* if <*parms> is a cut buffer insert its contents */
    if ( buffer >= 0 )
    {
	Atom	type = XA_STRING;
	Int     fmt8 = 8;
	Int     nbytes;
	String  line;
	UInt    length;

	line = XFetchBuffer( XtDisplay(w), &nbytes, buffer );
	if ( 0 < ( length = nbytes ) )
	    DoSelection( w, NULL, &selection, &type, (caddr_t) line,
			 &length, &fmt8 );
	else if ( 1 < nums )
	    GetSelection( w, time, parms+1, nums-1 );
    }
    else
    {
	struct _SelectionList * list;

	if ( --nums )
	{
	    list         = XtNew(struct _SelectionList);
	    list->params = parms + 1;
	    list->count  = nums;
	    list->time   = time;
	}
	else
	    list = NULL;
	XtGetSelectionValue( w, selection, XA_STRING,
	    (XtSelectionCallbackProc) DoSelection, (XtPointer)list, time );
    }
}


/****************************************************************************
**
*F  GapTextInsertChar( <w>, <evt>, <parms>, <nums> )  . . . . . . handle keys
**
**  DESCRIPTION
**    Handle a key event. 'GapTextInsertChar' calls the input callback method
**    with a one (or possible more) character string.
*/
static void GapTextInsertChar (
    Widget              w,
    XEvent            * evt,
    String            * parms,
    Cardinal          * nums )
{
    GapTextWidget       gap = (GapTextWidget) w;
    Int                 len;
    KeySym              keysym;
    String              ptr;
    char                buf[2];
    char                str[128];

    /* if no input call is registered return */
    if ( gap->gap.input_callback == 0 )
	return;

    /* convert key event into text string */
    len = XLookupString( &(evt->xkey), str, 128, &keysym, 0 );

    /* handle arrows keys, etc */
    if ( len == 0 )
    {
        len = 1;
        str[len] = 0;
        /* Switched Arrow Up and PageUp behaviour, and
           Arrow Down and PageDown behaviour resp., 22.3.1999 Max */
        if ( keysym == XK_Left )
            str[0] = CTR('B');
        else if ( keysym == XK_Up )
            str[0] = CTR('P');
        else if ( keysym == XK_Right )
            str[0] = CTR('F');
        else if ( keysym == XK_Down )
            str[0] = CTR('N');
        else if ( keysym == XK_Prior )
        {
            len = 2;
	    strcpy( str, "\001\020" );
        }
        else if ( keysym == XK_Next )
        {
            len = 2;
	    strcpy( str, "\001\016" );
        }
        else if ( keysym == XK_Home )
        {
            len = 2;
            strcpy( str, "\033<" );
        }
        else if ( keysym == XK_Insert )
            str[0] = CTR('L');
        else
            return;
    }

    /* and call the callback */
    buf[0] = '@';
    for ( ptr = str;  0 < len;  len--, ptr++ )
    {
	if ( CTR('@') < *ptr && *ptr <= CTR('Z') )
	{
	    buf[1] = '@' + *ptr;
	    gap->gap.input_callback( buf, 2 );
	}
	else if ( *str == '@' )
	{
	    buf[1] = '@';
	    gap->gap.input_callback( buf, 2 );
	}
	else
	    gap->gap.input_callback( ptr, 1 );
    }
    return;
}


/****************************************************************************
**
*F  GapTextSelectStart( <w>, <evt>, <parms>, <nums> ) . . . .  pointer select
*/
static void GapTextSelectStart (
    Widget              w,
    XEvent            * evt,
    String            * parms,
    Cardinal          * nums )
{
    GapTextWidget       gap = (GapTextWidget) w;
    TextWidget          ctx = (TextWidget) w;
    XawTextPosition     oldPos;
    XawTextPosition     newPos;

    /* save text position */
    oldPos = gap->text.insertPos;

    /* hide cursor,  it will be make visible again in 'GapTextExtendEnd' */
    XawTextDisplayCaret( w, False );

    /* call our superclass */
    XtCallActionProc( w, "select-start", evt, parms, *nums );

    /* and restore text position */
    if ( gap->gap.check_caret_pos != 0 )
        newPos = oldPos+gap->gap.check_caret_pos(gap->text.insertPos,oldPos);
    else
	newPos = oldPos;
    if ( newPos == oldPos )
	ctx->text.insertPos = oldPos;
    else
	XawTextSetInsertionPoint( w, newPos );
}


/****************************************************************************
**
*F  GapTextExtendAdjust( <w>, <evt>, <parms>, <nums> )  . . .  pointer adjust
*/
static void GapTextExtendAdjust (
    Widget              w,
    XEvent            * evt,
    String            * parms,
    Cardinal          * nums )
{
    GapTextWidget       gap = (GapTextWidget) w;
    TextWidget          ctx = (TextWidget) w;
    XawTextPosition     oldPos;

    /* save text position */
    oldPos = gap->text.insertPos;

    /* call our superclass */
    XtCallActionProc( w, "extend-adjust", evt, parms, *nums );

    /* and restore text position */
    ctx->text.insertPos = oldPos;

    /* XawTextSetInsertionPoint( w, oldPos ); */
}


/****************************************************************************
**
*F  GapTextExtendEnd( <w>, <evt>, <parms>, <nums> ) . . .  pointer select end
*/
static void GapTextExtendEnd (
    Widget              w,
    XEvent            * evt,
    String            * parms,
    Cardinal          * nums )
{
    GapTextWidget       gap = (GapTextWidget) w;
    TextWidget          ctx = (TextWidget) w;
    XawTextPosition     oldPos;

    /* save text position */
    oldPos = gap->text.insertPos;

    /* call our superclass */
    XtCallActionProc( w, "extend-end", evt, parms, *nums );

    /* and restore text position */
    ctx->text.insertPos = oldPos;

    /* show cursor again, it is hidden in 'GapTextSelectStart' */
    XawTextDisplayCaret( w, True );

    /* XawTextSetInsertionPoint( w, oldPos ); */
}


/****************************************************************************
**
*F  GapTextInitialize( <req>, <new>, <args>, <nums> ) . . . . make new widget
*/
static void GapTextInitialize (
    Widget	    request,
    Widget          new,
    ArgList         args,
    Cardinal      * nums )
{
    GapTextWidget   w = (GapTextWidget) new;
    Int             i;
    Int             tabs[64];
    Int             tab;

    /* initialize gap source and ascii sink */
    if ( request->core.height == DEFAULT_TEXT_HEIGHT )
	new->core.height = DEFAULT_TEXT_HEIGHT;
    w->text.source = XtCreateWidget( "textSource",
				     gapSrcObjectClass,
				     new,
				     args, *nums );
    w->text.sink   = XtCreateWidget( "textSink",
				     asciiSinkObjectClass,
				     new,
				     args, *nums );

    if ( w->core.height == DEFAULT_TEXT_HEIGHT )
	w->core.height = VMargins(w)+XawTextSinkMaxHeight(w->text.sink,1);
    w->gap.drop_gap_prompt = False;

    /* set tab stops */
    for ( i = 0, tab = 0;  i < 64;  i++) 
	tabs[i] = (tab += 8);
    XawTextSinkSetTabs( w->text.sink, 64, tabs );

    /* enable redisplay in text object */
    XawTextDisableRedisplay(new);
    XawTextEnableRedisplay(new);
}


/****************************************************************************
**
*F  GapTextDestroy( <w> )   . . . . . . . . . . . . destroy a gap text widget
*/
static void GapTextDestroy (
    Widget 	    w )
{
    GapTextWidget   gap = (GapTextWidget) w;

    if ( w == XtParent(gap->text.source) )
	XtDestroyWidget( gap->text.source );

    if ( w == XtParent(gap->text.sink) )
	XtDestroyWidget( gap->text.sink );
}


/****************************************************************************
**

*V  GapTextResources  . . . . . . . . . . . . . . . . . resources of gap text
*/
#define offset(field) XtOffset(GapTextWidget, gap.field)

static XtResource GapTextResources[] =
{
    /* gap text resources */
    { XtNinputCallback,  	XtCInputCallback,         XtRPointer,
      sizeof(char*),     	offset(input_callback),	  XtRPointer,
      0
    },
    { XtNcheckCaretPos,  	XtCCheckCaretPos,         XtRPointer,
      sizeof(char*),     	offset(check_caret_pos),  XtRPointer,
      0
    },

    /* other resources */
    { XtNtinyFont, 		XtCTinyFont, 		  XtRFontStruct,
      sizeof(XFontStruct*),	offset(tiny_font),	  XtRString,
      "-*-*-*-r-*-*-8-*-*-*-*-*-*-1"
    },
    { XtNsmallFont, 		XtCSmallFont, 		  XtRFontStruct,
      sizeof(XFontStruct*),	offset(small_font),	  XtRString,
      "-*-*-*-r-*-*-10-*-*-*-*-*-*-1"
    },
    { XtNnormalFont, 		XtCNormalFont, 		  XtRFontStruct,
      sizeof(XFontStruct*),	offset(normal_font),	  XtRString,
      "-*-*-*-r-*-*-13-*-*-*-*-*-*-1"
    },
    { XtNlargeFont, 		XtCLargeFont, 		  XtRFontStruct,
      sizeof(XFontStruct*),	offset(large_font),	  XtRString,
      "-*-*-*-r-*-*-15-*-*-*-*-*-*-1"
    },
    { XtNhugeFont, 		XtCHugeFont, 		  XtRFontStruct,
      sizeof(XFontStruct*),	offset(huge_font),	  XtRString,
      "-*-*-*-r-*-*-20-*-*-*-*-*-*-1"
    },
    { XtNtitlePosition,         XtCTitlePosition,         XtRString,
      sizeof(String),           offset(title_position),   XtRString,
      "middle"
    },
    { XtNpasteGapPrompt,        XtCPasteGapPrompt,        XtRBoolean,
      sizeof(Boolean),          offset(paste_gap_prompt), XtRString,
      "False"
    },
    { XtNquitGapCtrD,           XtCQuitGapCtrD,           XtRBoolean,
      sizeof(Boolean),          offset(quit_gap_ctrd),    XtRString,
      "False"
    },
    { XtNcolorModel,            XtCColorModel,            XtRString,
      sizeof(String),           offset(color_model),      XtRString,
      "default"
    },
    { XtNcolors,                XtCColors,                XtRString,
      sizeof(String),           offset(colors),           XtRString,
      "default"
    }
};

#undef offset


/****************************************************************************
**
*V  GapTextActions  . . . . . . . . . . . . . . . . . .  actions for gap text
*/
static XtActionsRec GapTextActions[] =
{
    { "gap-insert-char", 	GapTextInsertChar      },
    { "gap-insert-selection",   GapTextInsertSelection },
    { "gap-select-start",       GapTextSelectStart     },
    { "gap-extend-adjust",      GapTextExtendAdjust    },
    { "gap-extend-end",         GapTextExtendEnd       }
};


/****************************************************************************
**
*V  GapTextTranslations	. . . . . . . . . . . . . . . . . action translations
*/
static char GapTextTranslations[] =
"\
<Key>:           gap-insert-char()\n\
<Btn1Down>:      gap-select-start()\n\
<Btn1Motion>:    gap-extend-adjust()\n\
<Btn1Up>:        gap-extend-end( PRIMARY, CUT_BUFFER0 )\n\
<Btn2Down>:      gap-insert-selection( PRIMARY, CUT_BUFFER0 )\n\
";


/****************************************************************************
**
*V  gapTextWidgetClass	. . . . . . . . . . . . . . . . gap text class record
*/
GapTextClassRec gapTextClassRec =
{
  { /* Core fields        */
    /* superclass         */    (WidgetClass) &textClassRec,
    /* class_name         */    "GapText",
    /* widget_size        */    sizeof(GapRec),
    /* class_initialize   */    XawInitializeWidgetSet,
    /* class_part_init    */	NULL,
    /* class_inited       */    FALSE,
    /* initialize         */    GapTextInitialize,
    /* initialize_hook    */	NULL,
    /* realize            */    XtInheritRealize,
    /* actions            */    GapTextActions,
    /* num_actions        */    XtNumber(GapTextActions),
    /* resources          */    GapTextResources,
    /* num_resource       */    XtNumber(GapTextResources),
    /* xrm_class          */    NULLQUARK,
    /* compress_motion    */    TRUE,
#if HAVE_BROKEN_TEXT_EXPORE_COMPRESS
    /* compress_exposure  */    XtExposeNoCompress,
#else
    /* compress_exposure  */    XtExposeGraphicsExpose | XtExposeNoExpose,
#endif
    /* compress_enterleave*/	TRUE,
    /* visible_interest   */    FALSE,
    /* destroy            */    GapTextDestroy,
    /* resize             */    XtInheritResize,
    /* expose             */    XtInheritExpose,
    /* set_values         */    NULL,
    /* set_values_hook    */	NULL,
    /* set_values_almost  */	XtInheritSetValuesAlmost,
    /* get_values_hook    */	NULL,
    /* accept_focus       */    XtInheritAcceptFocus,
    /* version            */	XtVersion,
    /* callback_private   */    NULL,
    /* tm_table           */    GapTextTranslations,
    /* query_geometry	  */	XtInheritQueryGeometry
  },
  { /* Simple fields      */
    /* change_sensitive   */	XtInheritChangeSensitive
  },
  { /* Text fields        */
    /* empty              */    0
  },
  { /* Gap fields         */
    /* empty              */    0
  }
};

WidgetClass gapTextWidgetClass = (WidgetClass)&gapTextClassRec;


/****************************************************************************
**

*F  * * * * * * * * * * * * gap text source widget  * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  GapSrcInitialize( <req>, <new>, <args>, <nums> )  . . . . .new gap source
*/
static void GapSrcInitialize (
    Widget          request,
    Widget          new,
    ArgList         args,
    Cardinal      * nums )
{
    GapSrcObject    src = (GapSrcObject) new;

    /* initially we use a 16KByte output buffer */
    src->gap_src.size   = 16 * 1024;
    src->gap_src.buffer = XtMalloc(src->gap_src.size);
    src->gap_src.length = 0;
}


/****************************************************************************
**
*F  GapSrcDestroy( <w> )  . . . . . . . . . . . . destroy a gap source object
*/
static void GapSrcDestroy (
    Widget          w )
{
    GapSrcObject    src = (GapSrcObject) w;

    /* free the output buffer */
    XtFree( src->gap_src.buffer );
}


/****************************************************************************
**
*F  GapSrcReadText( <w>, <pos>, <text>, <len> ) . . . get a piece of our text
**
**  DESCRIPTION
**    'GapSrcReadText'  sets  the  pointer <text>.ptr  to  the  text  of  <w>
**    starting at position <pos> and length <len>.
**
**  RETURNS
**    'GapSrcReadText' returns the position relative to the beginning of text
**    of <w> of the last character in <text>.
*/
static XawTextPosition GapSrcReadText (
    Widget              w,
    XawTextPosition     pos,
    XawTextBlock      * text,
    unsigned long       length )
{
    GapSrcObject        src = (GapSrcObject) w;

    text->firstPos = pos;
    text->ptr      = src->gap_src.buffer + pos;
    text->length   = src->gap_src.length - pos;
    text->format   = FMT8BIT;
    if ( length < text->length )
        text->length = length;
    return pos + text->length;
}


/****************************************************************************
**
*F  GapSrcReplaceText( <w>, <start>, <end>, <text> )  .  replace a text piece
**
**  DESCRIPTION
**    Replace the text of <w>  starting with <start> and  ending before <end>
**    with the  text given in <text>.
**
**  RETURNS
**    Either 'XawEditDone' or 'XawPositionError'.
*/
static int GapSrcReplaceText (
    Widget 	        w,
    XawTextPosition     start,
    XawTextPosition     end,
    XawTextBlock      * text )
{
    GapSrcObject        src = (GapSrcObject) w;
    String              p;
    String              q;
    String              e;

    /* remove text from <start> to end */
    p = src->gap_src.buffer + start;
    q = src->gap_src.buffer + end;
    e = src->gap_src.buffer + src->gap_src.length;
    while ( p < e )
	*p++ = *q++;
    src->gap_src.length += start - end;

    /* now insert the new text */
    if ( 0 < text->length )
    {
	if ( src->gap_src.size < src->gap_src.length + text->length )
	{
	    src->gap_src.size += 16*1024 + text->length;
	    src->gap_src.buffer = XtRealloc( src->gap_src.buffer,
					     src->gap_src.size );
	}
	p = ( src->gap_src.buffer + src->gap_src.length ) - 1;
	q = p + text->length;
	e = src->gap_src.buffer + start;
	while ( e <= p )
	    *q-- = *p--;
	q = text->ptr;
	p = e;
	e = p + text->length;
	while ( p < e )
	    *p++ = *q++;
	src->gap_src.length += text->length;
    }
    return XawEditDone;
}


/****************************************************************************
**
*F  GapSrcScan( <w>, <pos>, <type>, <dir>, <cnt>, <inc> ) . . . . . scan text
**
**  DESCRIPTION
**    Scan the text in <w>.buffer for the <cnt>.th occurance of a boundary of
**    type <type>.  Start  the scan at position <pos>. If  <include> is  true
**    include the boundary in the returned position.
**
**  RETURNS
**    'Scan' returns the position of the boundary.
*/
static XawTextPosition GapSrcScan (
    Widget                  w,
    XawTextPosition         pos,
    XawTextScanType         type,
    XawTextScanDirection    dir,
    int     	            cnt,
    int	                    ind )
{
    GapSrcObject            src = (GapSrcObject) w;
    Int                     inc;
    String                  p;

    /* first or last position in our text */
    if ( type == XawstAll )
	return (dir == XawsdRight) ? src->gap_src.length : 0;
	
    /* set <pos> to a sensible value */
    if ( pos > src->gap_src.length )
        pos = src->gap_src.length;

    /* we cannot scan left of position 0 or right of the text end */
    if ( dir == XawsdRight && pos == src->gap_src.length )
	return src->gap_src.length;
    else if ( dir == XawsdLeft && pos == 0 )
	return 0;
    else if ( dir == XawsdLeft )
	pos--;

    /* <inc> is used to increment (decrement) <p> and <pos> */
    inc = (dir == XawsdRight) ? 1 : -1;
    
    /* handle different types of boundaries <cnt> times */
    switch ( type )
    {
	case XawstAll: /* is not possible */
	    return (dir == XawsdRight) ? src->gap_src.length : 0;
	    break;

	case XawstEOL: 
	case XawstParagraph: 
	    if ( dir == XawsdRight )
	    {
		for ( ;  0 < cnt;  cnt-- )
		{
		    p = src->gap_src.buffer + pos;
		    while ( pos < src->gap_src.length )
		    {
			if ( *p == '\n' )
			    break;
			pos++;  p++;
		    }
		    if ( src->gap_src.length < pos )
			return src->gap_src.length;
		    pos++;
		}
	    }
	    else
	    {
		for ( ;  0 < cnt;  cnt-- )
		{
		    p = src->gap_src.buffer + pos;
		    while ( 0 <= pos )
		    {
			if ( *p == '\n' )
			    break;
			pos--;  p--;
		    }
		    if ( pos < 0 )
			return 0;
		    pos--;
		}
	    }
	    if ( !ind )
		pos -= inc;
	    break;


	case XawstWhiteSpace: 
  	    for ( ;  0 < cnt;  cnt-- )
	    {
		Boolean	    nonSpace = FALSE;

		p = src->gap_src.buffer + pos;
		while ( 0 <= pos && pos < src->gap_src.length )
		{
		    if ( *p == ' ' || *p == '\t' || *p == '\n' )
		    {
			if ( nonSpace )
			    break;
		    }
		    else
			nonSpace = TRUE;
		    pos += inc;
		    p   += inc;
		}
		if ( pos < 0 )
		    return 0;
		if ( src->gap_src.length < pos )
		    return src->gap_src.length;
		pos += inc;
	    }
	    if ( !ind )
		pos -= inc;
	    break;

	case XawstPositions: 
	    pos += cnt * inc;
	    break;
    }
    if ( dir == XawsdLeft )
	pos++;

    /* set <pos> to a sensible value and return */
    if ( pos >= src->gap_src.length )
	return src->gap_src.length;
    else if ( pos < 0 )
	return 0;
    else
	return pos;
}


/****************************************************************************
**
*V  gapSrcObjectClass . . . . . . . . . . . . . . . . gap source class record
*/
GapSrcClassRec gapSrcClassRec =
{
  { /* core_class fields        */
    /* superclass               */      (WidgetClass) (&textSrcClassRec),
    /* class_name               */      "GapSrc",
    /* widget_size              */      sizeof(GapSrcRec),
    /* class_initialize         */      XawInitializeWidgetSet,
    /* class_part_initialize    */      NULL,
    /* class_inited             */      FALSE,
    /* initialize               */      (XtInitProc) GapSrcInitialize,
    /* initialize_hook          */      NULL,
    /* realize                  */      NULL,
    /* actions                  */      NULL,
    /* num_actions              */      0,
    /* resources                */      NULL,
    /* num_resources            */      0,
    /* xrm_class                */      NULLQUARK,
    /* compress_motion          */      FALSE,
    /* compress_exposure        */      FALSE,
    /* compress_enterleave      */      FALSE,
    /* visible_interest         */      FALSE,
    /* destroy                  */      GapSrcDestroy,
    /* resize                   */      NULL,
    /* expose                   */      NULL,
    /* set_values               */      NULL,
    /* set_values_hook          */      NULL,
    /* set_values_almost        */      NULL,
    /* get_values_hook          */      NULL,
    /* accept_focus             */      NULL,
    /* version                  */      XtVersion,
    /* callback_private         */      NULL,
    /* tm_table                 */      NULL,
    /* query_geometry           */      NULL,
    /* display_accelerator      */      NULL,
    /* extension                */      NULL
  },
  { /* textSrc_class fields     */
    /* Read                     */      (XawTextPosition (*)())GapSrcReadText,
    /* Replace                  */      (int (*)()) GapSrcReplaceText,
    /* Scan                     */      (XawTextPosition (*)()) GapSrcScan,
    /* Search                   */      XtInheritSearch,
    /* SetSelection             */      XtInheritSetSelection,
    /* ConvertSelection         */      XtInheritConvertSelection
  },
  { /* GapSrc_class fields     */
    /* Keep the compiler happy */       NULL
  }
};

WidgetClass gapSrcObjectClass = (WidgetClass)&gapSrcClassRec;


/* * * * * * * * * * * * * gap text widget functions  * * * * * * * * * * * */


/****************************************************************************
**

*F  CheckTextBlock( <block> ) . . . . . . . . check a block for special chars
*/
#if 0
static char * CheckTextBlockTmp = 0;

static void CheckTextBlock ( block )
    XawTextBlock *   block;
{
    unsigned char *  p;
    unsigned char *  q;
    unsigned int     i;
    unsigned int     s;

    p = (unsigned char*) block->ptr;
    for ( s = 0, i = 0;  i < block->length;  i++, p++ )
	if ( *p < 32 && *p != '\n' && *p != '\r' )
	    s++;
    if ( s == 0 )
	return;
    if ( CheckTextBlockTmp != 0 )
	XtFree(CheckTextBlockTmp);
    CheckTextBlockTmp = XtMalloc(block->length + s);
    p = (unsigned char*) block->ptr;
    q = (unsigned char*) CheckTextBlockTmp;
    for ( i = 0;  i < block->length;  i++, p++ )
    {
	if ( *p < 32 )
	{
	    *q++ = '^';
	    *q++ = *p + 'A';
	}
	else
	    *q++ = *p;
    }
    block->ptr = CheckTextBlockTmp;
}
#endif


/****************************************************************************
**
*F  GTPosition( <w> ) . . . . . . . . . . . . . . . .  return insertion point
*/
Int GTPosition ( w )
    Widget  w;
{
    GapTextWidget       gap = (GapTextWidget) w;

    return gap->text.insertPos;
}


/****************************************************************************
**
*F  GTSetPosition( <w>, <pos> ) . . . . . . . . . . . .  set insertion point
*/
void GTSetPosition ( w, pos )
    Widget  w;
    Int     pos;
{
    XawTextSetInsertionPoint( w, pos );
}


/****************************************************************************
**
*F  GTDelete( <w>, <dir>, <type> )  . . . . . . . . .  delete a piece of text
*/
void GTDelete ( w, dir, type )
    Widget	            w;
    XawTextScanDirection    dir;
    XawTextScanType         type;
{
    GapTextWidget           gap = (GapTextWidget) w;
    XawTextBlock            text;
    Int                     to;
    Int                     from;

    /* prepare text for update */
    _XawTextPrepareToUpdate(gap);
    gap->text.time = CurrentTime;

    /* find <to> and <from> */
    to = GapSrcScan(gap->text.source,gap->text.insertPos,type,dir,1,TRUE);

    if ( to == gap->text.insertPos )
	to = GapSrcScan(gap->text.source,gap->text.insertPos,type,dir,2,TRUE);
    if (dir == XawsdLeft)
    {
	from = to;
	to   = gap->text.insertPos;
    }
    else 
	from = gap->text.insertPos;

    /* remove text */
    text.length = 0;
    text.firstPos = 0;
    if ( _XawTextReplace( gap, from, to, &text ) )
    {
	XBell(XtDisplay(gap), 50);
	goto error;
    }
    gap->text.insertPos = from;
    gap->text.showposition = TRUE;
    _XawTextSetScrollBars(gap);

    /* do update */
error:
    _XawTextCheckResize(gap);
    _XawTextExecuteUpdate(gap);
    gap->text.mult = 1;
}


/****************************************************************************
**
*F  GTInsertText( <w>, <str>, <len> ) . . . . .  insert <str> into a gap text
**
**  DESCRIPTION
**    This functions insert the text pointed to by  <str> of length  <len> in
**    the gap text  widget at the current position.  It is the responsibility
**    of the caller to set the current insertion position.
*/
void GTInsertText ( w, str, len )
    Widget	        w;
    String              str;
    Int                 len;
{
    GapTextWidget       gap = (GapTextWidget) w;
    XawTextBlock        block;

    /* convert text into a text block */
    block.firstPos = 0;
    block.ptr      = (char*) str;
    block.format   = FMT8BIT;
    block.length   = len;
#if 0
    CheckTextBlock(&block);
#endif

    /* insert text at current position */
    XawTextReplace( w, gap->text.insertPos, gap->text.insertPos, &block );

    /* move insertion position */
    XawTextSetInsertionPoint( w, gap->text.insertPos+len );
}


/****************************************************************************
**
*F  GTReplaceText( <w>, <str>, <len> )  . . . . .  replace last line by <str>
**
**  DESCRIPTION
**    This  functions replaces the text right of the insert point by the text
**    pointed  to by <str> of length <len>.  It is the responsibility of  the
**    caller to set the current insertion position.
*/
void GTReplaceText ( w, str, len )
    Widget	        w;
    String              str;
    Int                 len;
{
    GapTextWidget       gap = (GapTextWidget) w;
    XawTextBlock        block;

    /* convert text into a text block */
    block.firstPos = 0;
    block.ptr      = (char*) str;
    block.format   = FMT8BIT;
    block.length   = len;
#if 0
    CheckTextBlock(&block);
#endif

    /* insert text at current position */
    XawTextReplace(w,gap->text.insertPos,gap->text.insertPos+len,&block);

    /* move insertion position */
    XawTextSetInsertionPoint( w, gap->text.insertPos+len );
}


/****************************************************************************
**
*F  GTMoveCaret( <w>, <rpos> )	. . . move caret relative to current position
*/
void GTMoveCaret ( w, rpos )
    Widget		w;
    Int                 rpos;
{
    GapTextWidget       gap = (GapTextWidget) w;
    Int                 pos;

    pos = gap->text.insertPos+rpos;
    if ( pos < 0 )
	pos = 0;
    if ( ((GapSrcObject)gap->text.source)->gap_src.length < pos )
	pos = ((GapSrcObject)gap->text.source)->gap_src.length;
    XawTextSetInsertionPoint( w, pos );
}


/****************************************************************************
**
*F  GTDeleteLeft( <w> )	. . . . . . . . . . . delete a char left of the caret
*/
void GTDeleteLeft ( w )
    Widget             	w;
{
    GapTextWidget       gap = (GapTextWidget) w;

    /* check if there is a character to the left */
    if ( gap->text.insertPos <= 0 )
	return;

    /* use 'GTDelete' */
    GTDelete( w, XawsdLeft, XawstPositions );
}
    

/****************************************************************************
**
*F  GTDeleteRight( <w> )  . . . . . . . . .  delete a char right of the caret
*/
void GTDeleteRight ( w )
    Widget             	w;
{
    GapTextWidget       gap = (GapTextWidget) w;

    /* check if there is a character to the right */
    if ( ((GapSrcObject)gap->text.source)->gap_src.length
         <=
	 gap->text.insertPos )
	return;

    /* use 'GTDelete' */
    GTDelete( w, XawsdRight, XawstPositions );
}
    

/****************************************************************************
**
*F  GTBell( <w> ) . . . . . . . . . . . . . . . . . . . . . . .  ring my bell
*/
void GTBell ( w )
    Widget  w;
{
    XBell( XtDisplay(w), 50 );
}


/****************************************************************************
**
*F  GTDropGapPrompt( <w>, <flag> )  . . . . . . . .  set drop gap prompt flag
*/
void GTDropGapPrompt ( w, flag )
    Widget          w;
    Boolean         flag;
{
    GapTextWidget   gap = (GapTextWidget) w;

    gap->gap.drop_gap_prompt = flag;
}


/****************************************************************************
**

*E  gaptext.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
