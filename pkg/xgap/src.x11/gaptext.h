/****************************************************************************
**
*W  gaptext.h                   XGAP source                      Frank Celler
**
*H  @(#)$Id: gaptext.h,v 1.2 1997/12/05 17:30:57 frank Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
**
**  The GapTextWidget is  intended to be used as   a simple front  end to the
**  text widget with a gap  text source and an ascii  sink attached to it. It
**  is a subclass of the standard text widget  supplied with X11R4 and should
**  work with X11R5 and X11R6.
*/
#ifndef _gaptext_h
#define _gaptext_h


/*****************************************************************************
**

*D  XtNinputCallback  . . . . . . . function to call in case of keyboard input
*D  XtNcheckCaretPos  . . . . . . . .  function to validate new caret position
*D  XtNtinyFont . . . . . . . . . . . . . .  tiny font for all graphic windows
*D  XtNsmallFont  . . . . . . . . . . . . . small font for all graphic windows
*D  XtNnormalFont . . . . . . . . . . . .  normal font for all graphic windows
*D  XtNlargeFont  . . . . . . . . . . . . . large font for all graphic windows
*D  XtNhugeFont . . . . . . . . . . . . . .  huge font for all graphic windows
*D  XtNtitlePosition  . . . . . . . . position of title in all graphic windows
*D  XtNquitGapCtrD  . . . . . . . . . . . . . . . . . . . .  quit gap on ctr-D
*D  XtNpasteGapPrompt . . . . . . . . paste 'gap>' prompt into gap talk window
*D  XtNcolorModel . . . . . . . .  color model to use in a gap graphics window
*D  XtNcolors . . . . . . . . . . . . .  colors to use in a gap graphic window
**
**  All other resources are defined in <X11/Xaw/Text.h>
*/
#define XtNinputCallback        "inputCallback"
#define XtCInputCallback        "InputCallback"

#define XtNcheckCaretPos        "checkCaretPos"
#define XtCCheckCaretPos        "CheckCaretPos"

#define XtNtinyFont		"tinyFont"
#define XtCTinyFont             "TinyFont"

#define XtNsmallFont		"smallFont"
#define XtCSmallFont            "SmallFont"

#define XtNnormalFont		"normalFont"
#define XtCNormalFont           "NormalFont"

#define XtNlargeFont		"largeFont"
#define XtCLargeFont            "LargeFont"

#define XtNhugeFont		"hugeFont"
#define XtCHugeFont          	"HugeFont"

#define XtNtitlePosition        "titlePosition"
#define XtCTitlePosition        "TitlePosition"

#define XtNquitGapCtrD		"quitGapCtrD"
#define XtCQuitGapCtrD		"QuitGapCtrD"

#define XtNpasteGapPrompt       "pasteGapPrompt"
#define XtCPasteGapPrompt       "PasteGapPrompt"

#define XtNcolorModel           "colorModel"
#define XtCColorModel           "ColorModel"

#define XtNcolors               "colors"
#define XtCColors               "Colors"


/****************************************************************************
**

*T  GapTextClassRec . . . . . . . . . . . . . . . . . . gap text class record
*/
typedef struct {int empty;} GapClassPart;

typedef struct _GapTextClassRec
{
    CoreClassPart       core_class;
    SimpleClassPart     simple_class;
    TextClassPart       text_class;
    GapClassPart        gap_class;
}
GapTextClassRec;

extern GapTextClassRec gapTextClassRec;


/****************************************************************************
**
*T  GapRec  . . . . . . . . . . . . . . . . . . . . . . . . gap widget record
*/
typedef struct
{
    /* function to call when receiving input */
    void 		(*input_callback)();

    /* function to position caret */
    Int 		(*check_caret_pos)();

    /* input buffer for unprocessed input */
    String              buffer;
    UInt                size;
    UInt                length;

    /* flags for paste options */
    Boolean		drop_gap_prompt;	/* current state */
    Boolean		paste_gap_prompt;	/* user setting  */

    /* fonts */
    XFontStruct	      * tiny_font;
    XFontStruct	      * small_font;
    XFontStruct	      * normal_font;
    XFontStruct	      * large_font;
    XFontStruct	      * huge_font;

    /* other resources */
    String              title_position;
    Boolean		quit_gap_ctrd;
    String              color_model;
    String              colors;
}
GapPart;

typedef struct _GapRec
{
    CorePart            core;
    SimplePart          simple;
    TextPart            text;
    GapPart             gap;
}
GapRec;


/****************************************************************************
**
*T  GapTextWidgetClass	. . . . . . . . . . . . . . . . . . .  class datatype
*/
typedef struct _GapTextClassRec	*GapTextWidgetClass;


/****************************************************************************
**
*T  GapTextWidget . . . . . . . . . . . . . . . . . . . . . instance datatype
*/
typedef struct _GapRec	        *GapTextWidget;


/****************************************************************************
**
*V  gapTextWidgetClass	. . . . . . . . . . . . . . . . . .  class definition
*/
extern WidgetClass gapTextWidgetClass;


/****************************************************************************
**

*T  GapSrcClassRec  . . . . . . . . . . . . . . . . . gap source class record
*/

typedef struct _GapSrcClassPart {char * empty;} GapSrcClassPart;

typedef struct _GapSrcClassRec
{
    ObjectClassPart     object_class;
    TextSrcClassPart    text_src_class;
    GapSrcClassPart     gap_src_class;
}
GapSrcClassRec;

extern GapSrcClassRec gapSrcClassRec;


/****************************************************************************
**
*T  GapSrcRec . . . . . . . . . . . . . . . . . . .  gap source object record
*/
typedef struct _GapSrcPart
{
    String              buffer;     /* buffer holding the text             */
    UInt                size;       /* size of buffer                      */
    UInt              * lines;      /* start of lines in <buffer>          */
    UInt                length;     /* size of text in <buffer>            */
}
GapSrcPart;

typedef struct _GapSrcRec
{
    ObjectPart          object;
    TextSrcPart         text_src;
    GapSrcPart          gap_src;
}
GapSrcRec;


/****************************************************************************
**
*T  GapSrcObjectClass . . . . . . . . . . . . . . . . . . . .  class datatype
*/
typedef struct _GapSrcClassRec *GapSrcObjectClass;


/****************************************************************************
**
*T  GapSrcObject  . . . . . . . . . . . . . . . . . . . . . instance datatype
*/
typedef struct _GapSrcRec *GapSrcObject;


/****************************************************************************
**
*V  gapSrcObjectClass . . . . . . . . . . . . . . . . . . .  class definition
*/
extern WidgetClass gapSrcObjectClass;


/****************************************************************************
**

*P  Prototypes  . . . . . . . . . . . prototypes of public gap text functions
*/
extern void GTBell( Widget );
extern void GTDeleteLeft( Widget );
extern void GTDeleteRight( Widget );
extern void GTInsertText( Widget, String, Int );
extern void GTMoveCaret( Widget, Int );
extern Int  GTPosition( Widget );
extern void GTReplaceText( Widget, String, Int );
extern void GTSetPosition( Widget, Int );
extern void GTDropGapPrompt( Widget, Boolean );

#endif


/****************************************************************************
**

*E  gaptext.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
