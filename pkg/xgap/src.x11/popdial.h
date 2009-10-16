/****************************************************************************
**
*W  popdial.h			XGAP source	                 Frank Celler
**
*H  @(#)$Id: popdial.h,v 1.2 1997/12/05 17:31:00 frank Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
**
**  This file contains functions for popping up dialogs.
*/
#ifndef _popdial_h
#define _popdial_h

#include    "utils.h"			/* utility functions */


/****************************************************************************
**

*D  PD_YES  . . . . . . . . . . . . . . . . . . . . . . . . exit button "yes"
*D  PD_NO   . . . . . . . . . . . . . . . . . . . . . . . .  exit button "no"
*D  PD_OK   . . . . . . . . . . . . . . . . . . . . . . . .  exit button "OK"
*D  PD_CANCEL   . . . . . . . . . . . . . . . . . . . .  exit button "cancel"
*D  PD_ABORT  . . . . . . . . . . . . . . . . . . . . . . exit button "abort"
*D  PD_RETRY  . . . . . . . . . . . . . . . . . . . . . . exit button "retry"
*D  PD_APPEND   . . . . . . . . . . . . . . . . . . . .  exit button "append"
*D  PD_OVERWRITE  . . . . . . . . . . . . . . . . . . exit button "overwrite"
*/
#define	PD_YES	        0x0001
#define PD_NO           0x0002
#define PD_OK           0x0004
#define PD_CANCEL       0x0008
#define PD_ABORT        0x0010
#define PD_RETRY        0x0020
#define PD_APPEND  	0x0040
#define PD_OVERWRITE	0x0080
#define PD_LAST         PD_OVERWRITE


/****************************************************************************
**
*T  TypePopupDialog . . . . . . . . . . . . . . . pointer to dialog structure
*/
typedef struct _popup_dialog
{
    Widget	    topLevel;
    Widget          popupShell;
    Widget          dialog;
    XtAppContext    context;
    Int             result;
    Int             button;
    Int             defaultButton;
    Widget          buttons[PD_LAST+1];
}
* TypePopupDialog;


/****************************************************************************
**
*P  Prototypes  . . . . . . . . . . . prototypes of public gap text functions
*/
extern TypePopupDialog CreatePopupDialog(
    XtAppContext,
    Widget,
    String,
    Int,
    Int,
    Pixmap );

extern Int PopupDialog( 
    TypePopupDialog,
    String,
    String,
    String* );

extern void PopupDialogBrokenWM(
    void );

#endif


/****************************************************************************
**

*E  popdial.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
