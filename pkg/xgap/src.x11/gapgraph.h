/****************************************************************************
**
*W  gapgraph.h                  XGAP source                      Frank Celler
**
*H  @(#)$Id: gapgraph.h,v 1.2 1997/12/05 17:30:50 frank Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
*/
#ifndef _gapgraph_h
#define _gapgraph_h


/****************************************************************************
**

*D  T_XXX . . . . . . . . . . . . . . . . . . . . . . . .  the graphic object
*/
#define T_LINE          1
#define T_CIRCLE        2
#define T_DISC          3
#define T_TEXT          4
#define T_RECT          5
#define T_BOX           6


/****************************************************************************
**
*D  C_XXX . . . . . . . . . . . . . . . . . . . . . . . . . .  the color XXXX
*/
#define C_BLACK		0
#define C_WHITE		1
#define C_LIGHT_GRAY	2
#define C_DARK_GRAY     3
#define C_LAST_GRAY     3
#define C_RED		4
#define C_BLUE		5
#define C_GREEN		6
#define C_LAST          6


/****************************************************************************
**
*D  CM_BW . . . . . . . . . . . . . . . . . . . . .  color model: black/white
*D  CM_GRAY . . . . . . . . . . . . . . . . . . . . . .  color model: 2 grays
*D  CM_COLOR3 . . . . . . . . . . . . . . . . . . . . . color model: 3 colors
*D  CM_COLOR5 . . . . . . . . . . . . . . . .  color model: 3 colors, 2 grays
*/
#define CM_BW		1
#define CM_GRAY		2
#define CM_COLOR3       3
#define CM_COLOR5       4


/****************************************************************************
**

*T  TypeGapGraphicObject  . . . . . . . . . . . . .  graphic object of widget
*/
typedef struct _gap_graphic_obj
{
    Short   type;
    Short   color;
    Int     x, y, w, h;
    union
    {
        struct { Int x1, x2, y1, y2, w;                }   line;
        struct { Int x, y, r, w;                       }   circle;
        struct { Int x, y, r;                          }   disc;
        struct { Int x, y, len; String str; Font font; }   text;
	struct { Int x1, x2, y1, y2, w;                }   rect;
	struct { Int x1, x2, y1, y2;                   }   box;
    } desc;
}
TypeGapGraphicObject;


/****************************************************************************
**
*T  GapGrahpicClassRec	. . . . . . . . . . . . . .  gap graphic class record
*/
typedef struct {
    int 		empty;
}
GapGraphicClassPart;

typedef struct _GapGraphicClassRec
{
    CoreClassPart       core_class;
    GapGraphicClassPart gap_graphic_class;
}
GapGraphicClassRec;

extern GapGraphicClassRec gapGraphicClassRec;


/****************************************************************************
**
*T  GapGarphicRec . . . . . . . . . . . . . . . . . gap graphic widget record
*/
typedef struct {

    /* dimension of window */
    UInt                width;
    UInt                height;

    /* reference number */
    Int                 number;

    /* list of graphic objects */
    TypeList            objs;

    /* display information */
    Display           * display;
    Pixel               black;
    Pixel               white;
    GC                  gc;

    /* bounding box to update */
    Boolean             update;
    Boolean             fast_update;
    Int                 lx,  hx;
    Int                 ly,  hy;
}
GapGraphicPart;

typedef struct _GapGraphicRec
{
    CorePart            core;
    GapGraphicPart      gap_graphic;
}
GapGraphicRec;


/****************************************************************************
**
*T  GapGraphicWidgetClass . . . . . . . . . . . . . . . . . .  class datatype
*/
typedef struct _GapGraphicClassRec * GapGraphicWidgetClass;


/****************************************************************************
**
*T  GapGraphicWidget  . . . . . . . . . . . . . . . . . . . instance datatype
*/
typedef struct _GapGraphicRec * GapGraphicWidget;


/****************************************************************************
**
*V  gapGraphicWidgetClass . . . . . . . . . . . . . . . . .  class definition
*/
extern WidgetClass gapGraphicWidgetClass;


/****************************************************************************
**

*P  Prototypes  . . . . . . . . . . . prototypes of public gap text functions
*/
extern Int     GCColorModel( Display* );
extern void    GCSetColorModel( Display*, Int, String );
extern Int     GGAddObject( Widget, TypeGapGraphicObject* );
extern void    GGFreeAllObjects( Widget );
extern void    GGFreeGapGraphicObjects( Widget );
extern void    GGFreeObject( TypeGapGraphicObject* );
extern Boolean GGRemoveObject( Widget, Int );
extern void    GGResize( Widget, Int, Int );
extern void    GGStartRemove( Widget );
extern void    GGStopRemove( Widget );
extern void    GGDrawObject( Widget, TypeGapGraphicObject*, Boolean );
extern void    GGFastUpdate( Widget, Boolean );

#endif


/****************************************************************************
**

*E  gapgraph.h 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
