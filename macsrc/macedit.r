/****************************************************************************
**
*W  macedit.r                   GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  some resources for the built-in text editor. The remaining resources are 
**  contained in the file 'macres.rsrc'.
*/
#include <Types.r>   /*BH: inserted #include */
#include <SysTypes.r>   /*BH: inserted #include */
#include <FileTypesAndCreators.r>   /*BH: inserted #include */
#include "macdefs.h"
/*------------------- Version -------------------*/

resource 'vers' (1) {
	16*(MAJORVER/10)+MAJORVER%10,
	16*(MINORVER/10)+MINORVER%10,
	RELEASESTATE,
	16*(RELEASE/10)+RELEASE%10,
	verUS,
	MACGAPVERS,
	MACGAPVERS" © Dept. of Maths, University of St. Andrews"
};

resource 'vers' (2) {
	16*(MAJORVER/10)+MAJORVER%10,
	16*(MINORVER/10)+MINORVER%10,
	RELEASESTATE,
	16*(RELEASE/10)+RELEASE%10,
	verUS,
    MACGAPVERS,
	"Groups, Algorithms, Programming"
};

#if BEACHBALL
resource 'acur' (160) {
	{	/* array CursIdArray: 4 elements */
		/* [1] */
		160,
		/* [2] */
		161,
		/* [3] */
		162,
		/* [4] */
		163
	}
};

resource 'CURS' (163, preload) {
	$"07C0 1F30 3F08 7F04 7F04 FF02 FF02 FFFE"
	$"81FE 81FE 41FC 41FC 21F8 19F0 07C0",
	$"07C0 1FF0 3FF8 7FFC 7FFC FFFE FFFE FFFE"
	$"FFFE FFFE 7FFC 7FFC 3FF8 1FF0 07C0",
	{7, 7}
};

resource 'CURS' (160, preload) {
	$"07C0 1FF0 3FF8 5FF4 4FE4 87C2 8382 8102"
	$"8382 87C2 4FE4 5FF4 3FF8 1FF0 07C0",
	$"07C0 1FF0 3FF8 7FFC 7FFC FFFE FFFE FFFE"
	$"FFFE FFFE 7FFC 7FFC 3FF8 1FF0 07C0",
	{7, 7}
};

resource 'CURS' (161, preload) {
	$"07C0 19F0 21F8 41FC 41FC 81FE 81FE FFFE"
	$"FF02 FF02 7F04 7F04 3F08 1F30 07C0",
	$"07C0 1FF0 3FF8 7FFC 7FFC FFFE FFFE FFFE"
	$"FFFE FFFE 7FFC 7FFC 3FF8 1FF0 07C0",
	{7, 7}
};

resource 'CURS' (162, preload) {
	$"07C0 1830 2008 701C 783C FC7E FEFE FFFE"
	$"FEFE FC7E 783C 701C 2008 1830 07C0",
	$"07C0 1FF0 3FF8 7FFC 7FFC FFFE FFFE FFFE"
	$"FFFE FFFE 7FFC 7FFC 3FF8 1FF0 07C0",
	{7, 7}
};
#endif

/*------------------- Strings -------------------*/

resource 'STR#' (128,purgeable) {
	{	/* array StringArray: */
		"Mark the selection with what name?",
		"\"^0\" is an existing marker. Do you want to replace it?",
		"Save this template as:",
		"Replace existing \"^0\"?",
/*5*/	"Delete which markers?",
		"Do you really want to discard the changes to \"^0\"?",
		"Not enough memory for this operation to be undone. Do you want to continue?"
#if GAPVER
		"Still not enough memory available for printing. Do you want try it anyway (GAP may crash!)?"
		"Not enough memory available for printing. Do you want to clear the log window?"
#else
		"Not enough memory available for printing. Do you want try it anyway (and risk a crash!)?"
#endif
	}
};

resource 'STR#' (130,purgeable) {
	{	/* array StringArray: */
#if TEMPMEM
		"Not enough memory to complete this operation"
		" - try closing open widows or quit other applications",
#else
		"Not enough memory to complete this operation"
		"try increasing the application's partition size",
#endif
#if GAPVER == 4
		"Not enough memory to complete this operation"
		"try to allocate more memory using the -a command line option",
#else
		"Not enough memory to complete this operation"
		"try increasing the application's partition size",
#endif
		"This file is locked or already in use. It will be read-only.",
		"Can't open any more documents!",	
/*5*/	"Can't open any more windows!",	
		"Could not save document.", 
		"Got Apple Event parameters I don't know what to do with.",
		"Wrong parameters Open/Print Apple Event",
		"Could not access data in Open/Print Apple Event",
/*10*/	"Error in number of files in Open/Print Apple Event",
		"Could not access data entry in Open/Print Apple Event",
		"Could not dispose of data in Open/Print Apple Event",
		"Unexpected error",
		"Can't get memory for colour table!",
#ifdef GAPVER
/*15*/	"Sorry, GAP requires System 7 or higher.",
#else
/*15*/	"Sorry, this program requires System 7 or higher.",
#endif
		"This type of file cannot be opened.",
		"Cannot access or save settings for text window. Will use defaults.",
		"This file is read-only.",
#ifdef GAPVER
        "Sorry, this version of GAP requires at least a 68020 processor.",
/*20*/  "Cannot close this document right now because GAP is reading from it.",
        "Cannot get a valid path name for this document.",
        "Could not close file.",
		"Could not delete all temporary files/folders.",
		"Apple event data strg too long",
		"Not enough memory to open file"
#endif
	}
};

resource 'STR#' (131,purgeable) {
	{	/* array StringArray: */
		"PlainText Worksheet",
		"Open document",
		"Untitled",
		"Save document as",
		"Save a copy as"
	}
};

/*------------------- Menus -------------------*/
#ifdef GAPVER
resource 'MENU' (128, "AppleMenu") {
	128,
	textMenuProc,
	0x7FFFFFFD,
	enabled,
	apple,
	{	/* array: 2 elements */
		/* [1] */
		ABOUTSTRING, noIcon, noKey, noMark, plain,
		/* [2] */
		"-", noIcon, noKey, noMark, plain
	}
};

#if 0
resource 'MENU' (129, "FileMenu") {
	129,
	textMenuProc,
	0x7FFFF403,
	enabled,
	"File",
	{	/* array: 13 elements */
		/* [1] */
		"New", noIcon, "N", noMark, plain,
		/* [2] */
		"Open…", noIcon, "O", noMark, plain,
		/* [3] */
		"-", noIcon, noKey, noMark, plain,
		/* [4] */
		"Close", noIcon, "W", noMark, plain,
		/* [5] */
		"Save", noIcon, "S", noMark, plain,
		/* [6] */
		"Save As…", noIcon, noKey, noMark, plain,
		/* [7] */
		"Save a Copy…", noIcon, noKey, noMark, plain,
		/* [8] */
		"Revert to Saved", noIcon, noKey, noMark, plain,
		/* [9] */
		"-", noIcon, noKey, noMark, plain,
		/* [10] */
		"Page Setup…", noIcon, noKey, noMark, plain,
		/* [11] */
		"Print…", noIcon, noKey, noMark, plain,
		/* [12] */
		"-", noIcon, noKey, noMark, plain,
		/* [13] */
		"Quit", noIcon, "Q", noMark, plain
	}
};
#endif

resource 'MENU' (129, "FileMenu") {
	129,
	textMenuProc,
	0x7FFFF403,
	enabled,
	"File",
	{	/* array: 17 elements */
		/* [1] */
		"New", noIcon, "N", noMark, plain,
		/* [2] */
		"Open…", noIcon, "O", noMark, plain,
		/* [3] */
		"Close", noIcon, "W", noMark, plain,
		/* [4] */
		"-", noIcon, noKey, noMark, plain,
		/* [5] */
		"Read…", noIcon, "R", noMark, plain,
		/* [6] */
		"LogTo…", noIcon, noKey, noMark, plain,
		/* [7] */
		"Interrupt GAP", noIcon, ".", noMark, plain,
		/* [8] */
		"-", noIcon, noKey, noMark, plain,
		/* [9] */
		"Save", noIcon, "S", noMark, plain,
		/* [10] */
		"Save As…", noIcon, noKey, noMark, plain,
		/* [11] */
		"Save a Copy…", noIcon, noKey, noMark, plain,
		/* [12] */
		"Revert to Saved", noIcon, noKey, noMark, plain,
		/* [13] */
		"-", noIcon, noKey, noMark, plain,
		/* [14] */
		"Page Setup…", noIcon, noKey, noMark, plain,
		/* [15] */
		"Print…", noIcon, noKey, noMark, plain,
		/* [16] */
		"-", noIcon, noKey, noMark, plain,
		/* [17] */
		"Quit", noIcon, "Q", noMark, plain
	}
};
#endif

resource 'MENU' (130, "EditMenu") {
	130,
	textMenuProc,
	0x7FFFFFFF,
	enabled,
	"Edit",
	{	/* array: 11 elements */
		/* [1] */
		"Undo", noIcon, "Z", noMark, plain,
		/* [2] */
		"-", noIcon, noKey, noMark, plain,
		/* [3] */
		"Cut", noIcon, "X", noMark, plain,
		/* [4] */
		"Copy", noIcon, "C", noMark, plain,
		/* [5] */
		"Paste", noIcon, "V", noMark, plain,
		/* [6] */
		"Clear", noIcon, noKey, noMark, plain,
		/* [7] */
		"Select All", noIcon, "A", noMark, plain,
		/* [8] */
		"-", noIcon, noKey, noMark, plain,
		/* [9] */
		"Show Clipboard", noIcon, noKey, noMark, plain,
		/* [10] */
		"-", noIcon, noKey, noMark, plain,
		/* [11] */
		"Wrap", noIcon, noKey, noMark, plain,
		/* [12] */
		"Auto indent", noIcon, noKey, noMark, plain,
		/* [13] */
		"Format…", noIcon, "Y", noMark, plain,
		/* [12] */
		"-", noIcon, noKey, noMark, plain,
		/* [13] */
		"Align", noIcon, noKey, noMark, plain,
		/* [14] */
		"Shift Right", noIcon, "]", noMark, plain,
		/* [15] */
		"Shift Left", noIcon, "[", noMark, plain,
#if PREFERENCES
		/* [16] */
		"-", noIcon, noKey, noMark, plain,
		/* [17] */
		"Preferences…", noIcon, noKey, noMark, plain,
#endif
	}
};

resource 'MENU' (131, "FindMenu") {
	131,
	textMenuProc,
	0x7FFFFF20,
	enabled,
	"Find",
	{	/* array: 9 elements */
		/* [1] */
		"Find…", noIcon, "F", noMark, plain,
		/* [2] */
		"Find same", noIcon, "G", noMark, plain,
		/* [3] */
		"Find selection", noIcon, "T", noMark, plain,
		/* [4] */
		"-", noIcon, noKey, noMark, plain,
		/* [5] */
		"Replace…", noIcon, "H", noMark, plain,
		/* [6] */
		"Replace Same", noIcon, "J", noMark, plain,
		/* [7] */
		"-", noIcon, noKey, noMark, plain,
		/* [8] */
		"Go to line… ", noIcon, "L", noMark, plain,
		/* [9] */
		"Scroll to selection", noIcon, noKey, noMark, plain
	}
};

#if MARKS
resource 'MENU' (132, "Mark") {
	132,
	textMenuProc,
	0x7FFFFFF8,
	enabled,
	"Mark",
	{	/* array: 4 elements */
		/* [1] */
		"Mark…", noIcon, "M", noMark, plain,
		/* [2] */
		"Unmark…", noIcon, noKey, noMark, plain,
		/* [3] */
		"Alphabetical", noIcon, noKey, noMark, plain,
		/* [4] */
		"-", noIcon, noKey, noMark, plain
	}
};
#endif


resource 'MENU' (133, "Window") {
	133,
	textMenuProc,
	0x7FFFFFFB,
	disabled,
	"Window",
	{	/* array: 6 elements */
		/* [1] */
		"Tile Windows", noIcon, noKey, noMark, plain,
		/* [2] */
		"Stack Windows", noIcon, noKey, noMark, plain,
		/* [3] */
		"-", noIcon, noKey, noMark, plain,
#ifdef GAPVER
		/* [4] */
		"Show garbage collections", noIcon, noKey, noMark, plain,
		/* [5] */
# if GAPVER == 4
		"Show partial collections", noIcon, noKey, noMark, plain,
		/* [5/6] */
# endif
		"Always scroll to printout", noIcon, noKey, noMark, plain,
		/* [6/7] */
		"-", noIcon, noKey, noMark, plain
#endif
	}
};

#ifdef GAPVER
resource 'STR#' (134, "Help menu items") {
	{	
		/* [1] */
		"Find selection in table of contents",
		/* [2] */
		"Find selection in index", 
		/* [3] */
		"Show completions",
		/* [4] */
		"-",
		/* [5] */
		"preceding section",
		/* [6] */
		"next section", 
		/* [7] */
		"preceding chapter",
		/* [8] */
		"next chapter",
		/* [9] */
		"-", 
# if GAPVER == 3
		/* [10] */
		"About GAP", 
		/* [11] */
		"Chapters", 
		/* [12] */
		"Copyright", 
		/* [13] */
		"About Help", 
# elif GAPVER == 4
		"Books", 
		/* [10] */
		"Chapters", 
		/* [11] */
		"Sections", 
		/* [12] */
		"Copyright", 
		/* [13] */
		"Authors", 
		/* [14] */
		"-", 
		/* [15] */
		"Welcome to GAP", 
		/* [16] */
		"About GAP for MacOS", 
		/* [17] */
		"About Help", 
# endif
	}
};
#endif

resource 'open' (128) {
	FCREATOR, {'TEXT'}
};


resource 'kind' (128)
{
   FCREATOR,
   verUS,
   {
      ftApplicationName,      MACGAPSHORTVERS,
      'TEXT',                 MACGAPSHORTVERS" text document",
      'BINA',                 MACGAPSHORTVERS" binary file"
   }
};


#if NEED_SIZE

resource 'SIZE' (-1, "") {
	reserved,
	acceptSuspendResumeEvents,
	reserved,
	canBackground,
	multiFinderAware,
	backgroundAndForeground,
	dontGetFrontClicks,
	ignoreAppDiedEvents,
	is32BitCompatible,
	isHighLevelEventAware,
	localAndRemoteHLEvents,
	notStationeryAware,
	dontUseTextEditServices,
	reserved,
	reserved,
	reserved,
	16384*1024,
	8000*1024
};

#endif