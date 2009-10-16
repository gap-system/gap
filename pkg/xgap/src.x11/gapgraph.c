/****************************************************************************
**
*W  gapgraph.c                  XGAP Source                      Frank Celler
**
*H  @(#)$Id: gapgraph.c,v 1.3 1998/12/18 18:58:08 gap Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
*/
#include    "utils.h"
#include    "gapgraph.h"


/****************************************************************************
**

*F  * * * * * * * * * * * * * * local variables * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  GcClear . . . . . . . . . . . . . . . . . . . . . . . used to clear areas
*/
static GC GcClear;


/****************************************************************************
**
*V  GcColormap  . . . . . . . . . . . . . . . . . . . . .  standard color map
*/
static Colormap GcColormap;


/****************************************************************************
**
*V  GcColors  . . . . . . . . . . . . . . . . . . . . . . . . . . color array
*/
static XColor GcColors[C_LAST+1];


/****************************************************************************
**

*F  * * * * * * * * * * * * *  gap graphic widget * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  GapGraphInitialize( <request>, <new>, <args>, <nums> )  open a new window
*/
static void GapGraphInitialize ( request, new, args, nums )
    Widget              request;
    Widget              new;
    ArgList             args;
    Cardinal          * nums;
{
    GapGraphicWidget	w = (GapGraphicWidget) new;
    XRectangle          rec[1];
    XGCValues           val;
    Display           * dis;
    static Boolean      first = True;

    /* store width and height of our new window */
    w->gap_graphic.width  = request->core.width;
    w->gap_graphic.height = request->core.height;
    w->gap_graphic.update = True;

    /* create a new list for the graphic objects */
    w->gap_graphic.objs = List(0);

    /* create a pixmap the picture */
    dis = XtDisplay(new);

    /* set display */
    w->gap_graphic.display = dis;

    /* create a graphic context for this window */
    val.function      = GXcopy; 
    val.plane_mask    = AllPlanes;
    val.foreground    = BlackPixel( dis, DefaultScreen(dis) );
    val.background    = WhitePixel( dis, DefaultScreen(dis) );
    val.line_width    = 0;
    val.line_style    = LineSolid;
    val.cap_style     = CapRound;
    val.fill_style    = FillSolid;
    w->gap_graphic.gc = XCreateGC(
		           dis, DefaultRootWindow(dis),
                           GCFunction     | GCPlaneMask | GCForeground
                           | GCBackground | GCLineWidth | GCLineStyle
                           | GCCapStyle   | GCFillStyle,  &val );

    /* if this is the first initialize the global <GcClear> */
    if ( first )
    {
	first = False;
	val.function   = GXcopy;
        val.plane_mask = AllPlanes;
	val.foreground = WhitePixel( dis, DefaultScreen(dis) );
	val.background = BlackPixel( dis, DefaultScreen(dis) );
	GcClear = XCreateGC(
		      dis, DefaultRootWindow(dis),
                      GCFunction|GCPlaneMask|GCForeground|GCBackground,
		      &val );
	GCColorModel(dis);
    }

    /* our viewport could be large then the window */
    rec->x = 0;
    rec->y = 0;
    rec->width  = w->gap_graphic.width;
    rec->height = w->gap_graphic.height;
    XSetClipRectangles( dis, w->gap_graphic.gc, 0, 0, rec, 1, YXSorted );
}


/****************************************************************************
**
*F  GapGraphDestroy( <w> )  . . . . . . . . . . . . . . . .  destroy a window
*/
static void GapGraphDestroy ( w )
    Widget              w;
{
    GGFreeGapGraphicObjects(w);
}


/****************************************************************************
**
*F  GapGraphResize( <w> ) . . . . . . . . . . . . . .  ignore resize requests
*/
static void GapGraphResize ( w )
    Widget              w;
{
    GapGraphicWidget	gap = (GapGraphicWidget) w;

    gap->core.width  = gap->gap_graphic.width;
    gap->core.height = gap->gap_graphic.height;
}


/****************************************************************************
**
*F  GapGraphExpose( <w>, <evt> )  . . . . . . . . . . . .  handle an exposure
**
**  The following is defined in "Xlib.h":
**
**    typedef struct {
**      int type;
**      unsigned long serial;
**      Bool send_event;
**      Display *display;
**      Window window;
**      int x, y;
**      int width, height;
**      int count;
**    } XExposeEvent;
**
**/
static void GapGraphExpose ( w, evt )
    Widget                  w;
    XExposeEvent          * evt;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;
    TypeList                objs = gap->gap_graphic.objs;
    TypeGapGraphicObject  * obj;
    Int 	            x1,  y1,  x2,  y2;
    UInt                    i;

    /* get the rectangle to be exposed */
    x1 = evt->x;           y1 = evt->y;
    x2 = x1+evt->width-1;  y2 = y1+evt->height-1;

    /* clear it */
    XFillRectangle( gap->gap_graphic.display, XtWindow(gap), GcClear,
		    x1, y1, x2-x1+1, y2-y1+1 );

    /* make a sanity check for the values */
    if ( x1 < 0 )  x1 = 0;
    if ( x2 < 0 )  return;
    if ( y1 < 0 )  y1 = 0;
    if ( y2 < 0 )  return;
    if ( gap->gap_graphic.width  <= x1 )  return;
    if ( gap->gap_graphic.width  <= x2 )  x2 = gap->gap_graphic.width-1;
    if ( gap->gap_graphic.height <= y1 )  return;
    if ( gap->gap_graphic.height <= y2 )  y2 = gap->gap_graphic.height-1;

    /* redraw only objects inside the rectangle */
    for ( i = 0;  i < LEN(objs);  i++ )
	if ( ELM(objs,i) != 0 )
	{
	    obj = (TypeGapGraphicObject*) ELM(objs,i);
	    if (    obj->x+obj->w < x1
		 || obj->y+obj->h < y1
		 || x2 < obj->x
		 || y2 < obj->y )
		continue;
	    GGDrawObject( w, (TypeGapGraphicObject*)ELM(objs,i), True );
	}

    /* flush X11 queue (WHY?) */
    XFlush( gap->gap_graphic.display );
}


/****************************************************************************
**
*V  gapGraphicWidgetClass . . . . . . . . . . . . . . . . widget class record
*/
GapGraphicClassRec gapGraphicClassRec =
{
  { 
    /* core fields              */
    /* superclass		*/	(WidgetClass) &widgetClassRec,
    /* class_name		*/	"GapGraphic",
    /* widget_size		*/	sizeof(GapGraphicRec),
    /* class_initialize		*/	NULL,
    /* class_part_initialize	*/	NULL,
    /* class_inited		*/	FALSE,
    /* initialize		*/	GapGraphInitialize,
    /* initialize_hook		*/	NULL,
    /* realize			*/	XtInheritRealize,
    /* actions			*/	NULL,
    /* num_actions		*/	0,
    /* resources		*/	NULL,
    /* num_resources		*/	0,
    /* xrm_class		*/	NULLQUARK,
    /* compress_motion		*/	TRUE,
    /* compress_exposure	*/	TRUE,
    /* compress_enterleave	*/	TRUE,
    /* visible_interest		*/	FALSE,
    /* destroy			*/	GapGraphDestroy,
    /* resize			*/	XtInheritResize,
        /* FIXME: Dirty Hack by Max, replaced: GapGraphResize,
           I absolutely do *not* know what that means! */
    /* expose			*/	GapGraphExpose,
    /* set_values		*/	NULL,
    /* set_values_hook		*/	NULL,
    /* set_values_almost	*/	XtInheritSetValuesAlmost,
    /* get_values_hook		*/	NULL,
    /* accept_focus		*/	NULL,
    /* version			*/	XtVersion,
    /* callback_private		*/	NULL,
    /* tm_table			*/	NULL,
    /* query_geometry		*/	XtInheritQueryGeometry,
    /* display_accelerator	*/	XtInheritDisplayAccelerator,
    /* extension		*/	NULL
  },

  {
    /* template fields          */
    /* dummy                    */      0
  }
};

WidgetClass gapGraphicWidgetClass = (WidgetClass)&gapGraphicClassRec;


/****************************************************************************
**

*F  * * * * * * * * * * * * * color model functions * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  GCColorModel( <dis> ) . . . . . . . . . . . . return the color model used
**
**  The following is defined in "Xlib.h":
**
**    typedef struct {
**	      XExtData *ext_data;
**	      VisualID visualid;
**    #if defined(__cplusplus) || defined(c_plusplus)
**	      int c_class;
**    #else
**	      int class;
**    #endif
**	      unsigned long red_mask, green_mask, blue_mask;
**	      int bits_per_rgb;
**	      int map_entries;
**    } Visual;
*/
static Short  gcColorModel = -1;

static String ColorName[C_LAST+1] = {
  "black", "white", "light grey", "dim grey", "red", "blue", "green"
};

Int GCColorModel ( dis )
    Display   * dis;
{
    Int         diff,  a;
    Short       i;
    XColor      c, d;
    int	        cm;		/* as defined in 'Visual' */

    if ( gcColorModel == -1 )
    {
	cm = DefaultVisual( dis, DefaultScreen(dis) )->class;
	GcColormap = DefaultColormap( dis, DefaultScreen(dis) );

	/* reset colors */
	XAllocNamedColor( dis, GcColormap, "black", &c, &d );
	for ( i = 0;  i <= C_LAST;  i++ )
	    GcColors[i] = c;

	/* allocate black and white */
	for ( i = 0;  i <= 1;  i++ )
	{
	    XAllocNamedColor( dis, GcColormap, ColorName[i], &c, &d );
	    GcColors[i] = c;
	}
	gcColorModel = CM_BW;

	/* allocate gray */
	diff = 0;
	for ( i = 2;  i <= C_LAST_GRAY;  i++ )
	{
	    XAllocNamedColor( dis, GcColormap, ColorName[i], &c, &d );
	    GcColors[i] = c;
	    a = (c.red+c.green+c.blue)-(d.red+c.green+c.blue);
	    if ( a < 0 )  diff -= a;  else diff += a;
	    if ( c.red+c.green+c.blue == 0 )
		diff = 65536;
	}
	if ( diff < 300 )
	    gcColorModel = CM_GRAY;

	/* allocate color */
	if ( cm != StaticGray && cm != GrayScale )
	{
	    diff = 0;
	    for ( i = C_LAST_GRAY+1;  i <= C_LAST;  i++ )
	    {
		XAllocNamedColor( dis, GcColormap, ColorName[i], &c, &d );
		a = (c.red+c.green+c.blue)-(d.red+c.green+c.blue);
		if ( a < 0 )  diff -= a;  else diff += a;
		GcColors[i] = c;
		if ( c.red+c.green+c.blue == 0 )
		    diff = 65536;
	    }
	    if ( diff < 300 )
		gcColorModel = (gcColorModel==CM_GRAY)?CM_COLOR5:CM_COLOR3;
	}
    }
    return gcColorModel;
}


/****************************************************************************
**
*F  GCSetColorModel( <dis>, <mod> ) . . . . . . . . . . . . . set color model
*/
void GCSetColorModel ( dis, mod, colors )
    Display   * dis;
    Int         mod;
    String      colors;
{
    Int         e[10];
    Int         i,  j;		/* loop variables */
    Int         p;
    Int         s[10];
    String      ptr;		/* pointer into <tmp> */
    String      tmp;        	/* start of split <colors> */
    XColor      c, d;		/* allocated color */

    if ( gcColorModel != -1 )
	return;
    GcColormap = DefaultColormap( dis, DefaultScreen(dis) );

    /* reset colors */
    XAllocNamedColor( dis, GcColormap, "black", &c, &d );
    for ( i = 0;  i <= C_LAST;  i++ )
	GcColors[i] = c;

    /* set color names */
    if ( strcmp( colors, "default" ) )
    {
	tmp = XtMalloc(strlen(colors)+1);
	strcpy( tmp, colors );
	for ( i = 0, ptr = tmp;  i <= C_LAST && *ptr;  i++ )
	{
	    if ( *ptr == ',' )
		ptr++;
	    else
	    {
		ColorName[i] = ptr;
		while ( *ptr && *ptr != ',' )
		    ptr++;
		if ( *ptr )
		    *ptr++ = 0;
	    }
	}
    }

    /* find ranges for color names */
    p = 0;
    switch ( mod )
    {
	case CM_BW:
	    s[p] = 0;  e[p++] = 1;
	    break;
	case CM_GRAY:
	    s[p] = 0;  e[p++] = C_LAST_GRAY;
	    break;
	case CM_COLOR3:
	    s[p] = 0;  e[p++] = 1;
	    s[p] = C_LAST_GRAY+1;  e[p++] = C_LAST;
	    break;
	case CM_COLOR5:
	    s[p] = 0;  e[p++] = C_LAST;
	    break;
        default:
	    s[p] = 0;  e[p++] = 1;
	    mod = CM_BW;
	    break;
    }

    /* set color model */
    gcColorModel = mod;

    /* allocate colors */
    for ( i = 0;  i < p;  i++ )
	for ( j = s[i];  j <= e[i];  j++ )
	{
	    XAllocNamedColor( dis, GcColormap, ColorName[j], &c, &d );
	    GcColors[j] = c;
	}
}


/****************************************************************************
**

*F  * * * * * * * * * * * gap graphic widget functions  * * * * * * * * * * *
*/


/****************************************************************************
**

*F  GGDrawObject( <w>, <obj>, <flag> )  . . . . . . . . . . .  draw an object
*/
void GGDrawObject ( w, obj, flag )
    Widget	            w;
    TypeGapGraphicObject  * obj;
    Boolean                 flag;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;
    GC                      gc;

    if ( flag )
    {
	gc = gap->gap_graphic.gc;
	XSetForeground( gap->gap_graphic.display, gc,
		        GcColors[obj->color].pixel );
    }
    else
	gc = GcClear;
    switch ( obj->type )
    {
	case T_LINE:
	    XSetLineAttributes( gap->gap_graphic.display, gc,
			        obj->desc.line.w, LineSolid,
			        CapButt, JoinRound );
	    XDrawLine( gap->gap_graphic.display, XtWindow(gap), gc,
		       obj->desc.line.x1, obj->desc.line.y1,
		       obj->desc.line.x2, obj->desc.line.y2 );
	    break;

	case T_CIRCLE:
	    XSetLineAttributes( gap->gap_graphic.display, gc,
			        obj->desc.circle.w, LineSolid,
			        CapButt, JoinRound );
	    XDrawArc( gap->gap_graphic.display, XtWindow(gap), gc,
		      obj->desc.circle.x, obj->desc.circle.y,
		      obj->desc.circle.r, obj->desc.circle.r,
		      0, 360*64 );
	    break;

	case T_DISC:
	    XFillArc( gap->gap_graphic.display, XtWindow(gap), gc,
		      obj->desc.disc.x, obj->desc.disc.y,
		      obj->desc.disc.r, obj->desc.disc.r,
		      0, 360*64 );
	    break;

	case T_RECT:
	    XSetLineAttributes( gap->gap_graphic.display, gc,
			        obj->desc.rect.w, LineSolid,
			        CapButt, JoinRound );
	    XDrawRectangle( gap->gap_graphic.display, XtWindow(gap), gc,
			    obj->desc.rect.x1,
			    obj->desc.rect.y1,
			    obj->desc.rect.x2-obj->desc.rect.x1,
			    obj->desc.rect.y2-obj->desc.rect.y1 );
	    break;

	case T_BOX:
	    XFillRectangle( gap->gap_graphic.display, XtWindow(gap), gc,
			    obj->desc.rect.x1,
			    obj->desc.rect.y1,
			    obj->desc.rect.x2-obj->desc.rect.x1+1,
			    obj->desc.rect.y2-obj->desc.rect.y1+1 );
	    break;

	case T_TEXT:
	    XSetFont( gap->gap_graphic.display, gc,
		      obj->desc.text.font );
	    XDrawString( gap->gap_graphic.display, XtWindow(gap), gc,
			 obj->desc.text.x, obj->desc.text.y,
			 obj->desc.text.str, obj->desc.text.len );
	    break;
    }
}


/****************************************************************************
**
*F  GGAddObject( <w>, <obj> )	. . . . . . . . . . add to widget and draw it
*/
Int GGAddObject ( w, obj )
    Widget	            w;
    TypeGapGraphicObject  * obj;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;
    TypeList                objs = gap->gap_graphic.objs;
    Int		    	    i;

    /* draw object */
    GGDrawObject( w, obj, True );

    /* find free position in object list */
    for ( i = 0;  i < LEN(objs);  i++ )
	if ( ELM(objs,i) == 0 )
	    break;

    /* add element to the next free position */
    if ( i < LEN(objs) )
	ELM(objs,i) = (Pointer) obj;
    else
	AddList( objs, (Pointer) obj );

    /* and return the position number as object id */
    return i;
}


/****************************************************************************
**
*F  GGFreeObject( <obj> )  . . . . . . . . . . . . free memory used by <obj>
*/
void GGFreeObject ( obj )
    TypeGapGraphicObject      * obj;
{
    switch ( obj->type )
    {
	case T_LINE:
	case T_CIRCLE:
	case T_DISC:
	    break;
	case T_TEXT:
	    XtFree(obj->desc.text.str);
	    break;
    }
    XtFree((char*)obj);
}
   

/****************************************************************************
**
*F  GGRemoveObject( <w>, <pos> ) . . . . . . . . . . remove and undraw <obj>
*/
Boolean GGRemoveObject ( w, pos )
    Widget	            w;
    Int                     pos;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;
    TypeList                objs = gap->gap_graphic.objs;
    TypeGapGraphicObject  * obj;
    XExposeEvent            evt;

    /* find graphic object and clear entry */
    if ( ( obj = (TypeGapGraphicObject*) ELM(objs,pos) ) == 0 )
	return True;
    ELM(objs,pos) = 0;

    /* update this region */
    if ( gap->gap_graphic.fast_update )
    {
	if ( -1==gap->gap_graphic.lx || obj->x<gap->gap_graphic.lx )
	    gap->gap_graphic.lx = obj->x;
	if ( -1==gap->gap_graphic.ly || obj->y<gap->gap_graphic.ly )
	    gap->gap_graphic.ly = obj->y;
	if ( -1==gap->gap_graphic.hx || gap->gap_graphic.hx<=obj->x+obj->w )
	    gap->gap_graphic.hx = obj->x+obj->w+1;
	if ( -1==gap->gap_graphic.hy || gap->gap_graphic.hy<=obj->y+obj->h )
	    gap->gap_graphic.hy = obj->y+obj->h+1;
	GGDrawObject( w, obj, False );
    }
    else if ( gap->gap_graphic.update )
    {
	evt.x      = obj->x;
	evt.y      = obj->y;
	evt.width  = obj->w;
	evt.height = obj->h;
	GapGraphExpose( w, &evt );
    }
    else
    {
	if ( -1==gap->gap_graphic.lx || obj->x<gap->gap_graphic.lx )
	    gap->gap_graphic.lx = obj->x;
	if ( -1==gap->gap_graphic.ly || obj->y<gap->gap_graphic.ly )
	    gap->gap_graphic.ly = obj->y;
	if ( -1==gap->gap_graphic.hx || gap->gap_graphic.hx<=obj->x+obj->w )
	    gap->gap_graphic.hx = obj->x+obj->w+1;
	if ( -1==gap->gap_graphic.hy || gap->gap_graphic.hy<=obj->y+obj->h )
	    gap->gap_graphic.hy = obj->y+obj->h+1;
    }

    /* free memory and return that we did something */
    GGFreeObject(obj);
    return False;
}


/****************************************************************************
**
*F  GGStartRemove( <w> ) . . . . . . . . . . . . start a sequence of removes
*/
void GGStartRemove ( w )
    Widget	            w;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;

    gap->gap_graphic.update = False;
    gap->gap_graphic.lx     = -1;
    gap->gap_graphic.hx     = -1;
    gap->gap_graphic.ly     = -1;
    gap->gap_graphic.hy     = -1;
}


/****************************************************************************
**
*F  GGStopRemove( <w> )  . . .  stop a sequence of removes and update window
*/
void GGStopRemove ( w )
    Widget	            w;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;
    XExposeEvent            evt;

    gap->gap_graphic.update = True;
    evt.x      = gap->gap_graphic.lx;
    evt.y      = gap->gap_graphic.ly;
    evt.width  = gap->gap_graphic.hx - gap->gap_graphic.lx + 1;
    evt.height = gap->gap_graphic.hy - gap->gap_graphic.ly + 1;
    GapGraphExpose( w, &evt );
}


/****************************************************************************
**
*F  GGFastUpdate( <w>, <flag> ) . . . . . . . . . . .  en/disable fast update
*/
void GGFastUpdate ( w, flag )
    Widget		w;
    Boolean             flag;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;
    XExposeEvent            evt;

    if ( gap->gap_graphic.fast_update == flag || !gap->gap_graphic.update )
	return;
    gap->gap_graphic.fast_update = flag;
    if ( !flag )
    {
	evt.x      = gap->gap_graphic.lx;
	evt.y      = gap->gap_graphic.ly;
	evt.width  = gap->gap_graphic.hx - gap->gap_graphic.lx + 1;
	evt.height = gap->gap_graphic.hy - gap->gap_graphic.ly + 1;
	GapGraphExpose( w, &evt );
    }
    else
    {
	gap->gap_graphic.lx = -1;
	gap->gap_graphic.hx = -1;
	gap->gap_graphic.ly = -1;
	gap->gap_graphic.hy = -1;
    }

}


/****************************************************************************
**
*F  GGFreeAllObjects( <w> )  . . . . .  remove and undraw all window objects
*/
void GGFreeAllObjects ( w )
    Widget	        w;
{
    GapGraphicWidget    gap = (GapGraphicWidget) w;
    TypeList            objs = gap->gap_graphic.objs;
    Int                 i;

    for ( i = 0;  i < LEN(objs);  i++ )
	if ( ELM(objs,i) != 0 )
	    GGFreeObject(ELM(objs,i));
    XFillRectangle( gap->gap_graphic.display, XtWindow(gap), GcClear,
		    0, 0, gap->gap_graphic.width, gap->gap_graphic.height );
    LEN(objs) = 0;
}


/****************************************************************************
**
*F  GGFreeGapGraphicObjects( <w> ) free all objects/list associated with <w>
*/
void GGFreeGapGraphicObjects ( w )
    Widget	w;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;
    TypeList                objs = gap->gap_graphic.objs;

    if ( objs == 0 )
	return;
    GGFreeAllObjects(w);
    XtFree((char*)(objs->ptr));
    XtFree((char*)(objs));
    gap->gap_graphic.objs = 0;
}


/****************************************************************************
**
*F  GGResize( <w> )  . . . . . . . . . . . . . . . . . . . . . .  resize <w>
*/
void GGResize ( w, width, height )
    Widget	            w;
    Int                     width;
    Int                     height;
{
    GapGraphicWidget        gap = (GapGraphicWidget) w;
    XtWidgetGeometry        req;
    XRectangle              rec[1];

    /* enter new dimensions */
    req.width  = gap->gap_graphic.width  = width;
    req.height = gap->gap_graphic.height = height;
    req.request_mode = CWWidth | CWHeight;

    /* and make request, ignore the result */
    XtMakeGeometryRequest( w, &req, 0 );
    XtResizeWidget( w, (Dimension) width, (Dimension) height, 0 );
    gap->gap_graphic.width  = gap->core.width  = width;
    gap->gap_graphic.height = gap->core.height = height;

    /* and set new clipping */
    rec->x = 0;
    rec->y = 0;
    rec->width  = gap->gap_graphic.width;
    rec->height = gap->gap_graphic.height;
    XSetClipRectangles(XtDisplay(w),gap->gap_graphic.gc,0,0,rec,1,YXSorted);
}


/****************************************************************************
**

*E  gapgraph.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/

