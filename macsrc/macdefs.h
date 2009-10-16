/****************************************************************************
**
*W  macdefs.h                   GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. The 
**  declarations intended only for the Mac-specific files should go into
**  macdefs.h if they are to be used by the resource compiler as well,
**  otherwise into macedit.h.  
**  The declarations which must be included in every GAP source file are in 
**  'macheaders.h',
*/

/* some information needed for GAP */

#ifndef GAPVER
# define GAPVER 4          /* console for GAP 4 */
#endif

#if GAPVER == 3
# define MAJORVER 3          /* major version number  */
# define MINORVER 44         /* minor version number */
# define RELEASESTATE final  /* development, alpha, beta, final = release */
# define RELEASE 0           /* release number */
# define MACGAPVERS "3r4p5 fix 0 MacOS"
# define MACGAPSHORTVERS "GAP 3.4"
# define DATE __DATE__
# elif GAPVER == 4
# define MAJORVER 4          /* major version number  */
# define MINORVER 47        /* minor version number */
# define RELEASESTATE final  /* development, alpha, beta, final = release */
# define RELEASE   1        /* release number */
# define MACGAPVERS "4.4.7 MacOS"
# define MACGAPSHORTVERS "GAP 4.4.7"
# define DATE __DATE__       /*"2 November, 1999" */
#endif

#define COMPILER "CW Pro 5"

/* settings for text editor, note that some of these options haven't been tested */

#define MARKS 0               /* 1 = allow the user to set marks (didn't work properly anyway */
#define STATE 1               /* 1 = use/save window positions, fonts, etc. */
#define BEACHBALL 0           /* 1 = use animated cursor */
#define TEMPMEM 1             /* 1 = open files and the help messages are stored in temporary memory */
#define DEBUG 0               /* turns various debug features on or off */
#define DEBUG_UPDATE 0        /* debugs screen updates */
#define DEBUG_CONSOLEPOS 0    /* debug consoe read/write position */
#define DEBUG_DIALOG 0        /* debug options dialog */


#if GAPVER == 4
#define FCREATOR 'GAP4'     /* Macintosh file creator for GAP for the Mac */
#elif GAPVER == 3
#define FCREATOR 'MGAP'
#endif

#define ABOUTSTRING "About GAP for the Mac…"

#if GAPVER == 4
# define HELP_WINDOW 0         
# define PREFERENCES 0  /* we do not have an editable preferences dialog (yet) */
#define IC_SUPPORT 1
#elif GAPVER == 3
# define HELP_WINDOW 1         /* additional Help features */
# define PREFERENCES 1  /* we have an editable preferences dialog for GAP 3 */
#define IC_SUPPORT 0
#endif

#if GAPVER == 3
# define MAXLOGSIZE 0x8000
# define WORKSPACESIZE 0x10000
#endif

#define MAXWINDS 16

#define DONT_USE_ANSI_LIB 0 /* set to 1 to find out which ANSI functions are being required */
    /* if set to 0, make sure functions such as assert() send their output to the log */

/* some settings for the TE32K text engine */

#define	EXTRALINESTARTS		32    
#define	EXTRATEXTBUFF		1024
#define ASCONSOLE           1       /* we need some additional markers for the console window */

/* settings for resource compiler */

#define NEED_SIZE 0 /* set to 1 if compiler does not automatically create size resource */

#define SCROLLBAR_WIDTH 16

/* File Menu Items */
#define iNew				1
#define iOpen				2
#define iClose				3
/* --- */
#define iRead				5
#define iLogTo				6
#define iStop              7
/* --- */
#define iSave				9
#define iSaveAs				(iSave+1)
#define iSaveACopy			(iSave+2)
#define iRevert				(iSave+3)
/* --- */
#define iPageSetup			(iSave+5)
#define iPrint				(iPageSetup + 1)
/* --- */
#define iQuit				(iPageSetup + 3)

/* Edit Menu Items */
#define iUndo				1
/* --- */
#define iCut				3
#define iCopy				4
#define iPaste				5
#define iClear				6
#define iSelectAll			7
/* --- */
#define iShowClipboard		9
/* --- */
#define iWrap				11
#define iAutoIndent			(iWrap + 1)
#define iFormat				(iWrap + 2)
/* --- */
#define iAlign				(iWrap + 4)
#define iShiftRight			(iAlign + 1)
#define iShiftLeft			(iAlign + 2)
#if PREFERENCES
/* --- */
#  define iPreferences 		(iAlign + 4)
#endif

/* Find Menu Items */
#define iFind				1
#define iFindSame			2
#define iFindSelection		3
/* --- */
#define iReplace			5
#define iReplaceSame		6
/* --- */
#define iFindLine           8
#define iDisplaySelection	9

#if MARKS
/* Mark Menu Items */
#define iMark				1
#define iUnmark				2
#define iAlphabetical		3
#endif

/* Window Menu Items */
#define iTileWindows		1
#define iStackWindows		2
/* --- */
#ifdef GAPVER
# define iShowGarbageCollect 4
# if GAPVER == 4
#  define iShowPartial		5
#  define iScrollLog          6
#  define iLastWindowMenuItem 7
# else
#  define iScrollLog          5
#  define iLastWindowMenuItem 6
# endif
#endif


#ifdef GAPVER
/* Help menu items, relative positions */
# define iHelpSelectionRel 		1
# define iFindIndexRel			2
# define iShowCompletionsRel		3
/* --- */
# define iPrecSectionRel 		5
# define iNextSectionRel			(iPrecSectionRel + 1)
# define iPrevChapterRel			(iPrecSectionRel + 2)
# define iNextChapterRel			(iPrecSectionRel + 3)
# if GAPVER == 3
#  define iIntroductionRel		(iNextChapterRel + 2)
#  define iChaptersRel			(iIntroductionRel + 1)
#  define iCopyrightRel			(iIntroductionRel + 2)
#  define iHelpHelpRel			(iIntroductionRel + 3)
#  define iLastInHelpMenuRel		iHelpHelpRel
# elif GAPVER == 4
#  define iBooksRel				(iNextChapterRel + 2)
#  define iChaptersRel			(iBooksRel + 1)
#  define iSectionsRel			(iBooksRel + 2)
#  define iCopyrightRel			(iBooksRel + 3)
#  define iAuthorsRel				(iBooksRel + 4)
#  define iIntroductionRel		(iBooksRel + 6)
#  define iMacGAPRel				(iBooksRel + 7)
#  define iHelpHelpRel			(iBooksRel + 8)
#  define iLastInHelpMenuRel		iHelpHelpRel
# endif
#endif

#define LINEDIALOG_ID 600
#define iLineNo 4

/* Printing Parameters */

#define LeftMargin			36
#define TopMargin			36
#define BottomMargin		36

#define gMyScrpHandle TE32KScrpHandle
#define gMyScrpLength TE32KScrpLength

#define	nullStopMask 0

#define rProcessFilesDialog 132
#define rMoreOptions 134
#define rRequestDialog 135
#define rUnmarkDialog 136
#define rConfirmDialog 141
#define rRoseParameters 142
#define rConfigureDataPage 143
#define TitlePageDialog 138
#define DataPageDialog 139
#define	MessageDialog 258

#define DESK_ID	128
#define	FILE_ID	129
#define EDIT_ID	130
#define FIND_ID	131
#if MARKS
#define MARK_ID	132
#endif

#define WINDOW_ID 133
#ifdef GAPVER
#define HELP_ITEMS_ID 134
#endif
