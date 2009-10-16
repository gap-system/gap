/****************************************************************************
**
*W  macte.c                     GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the declaration part for the text engine (a TextEdit replacement) for the 
**  built-in text editor.
*/
#if !TARGET_API_MAC_CARBON
#ifndef __TYPES__
#include <Types.h>
#endif

#ifndef __QUICKDRAW__
#include <Quickdraw.h>
#endif

#ifndef __MEMORY__
#include <Memory.h>
#endif

#ifndef __EVENTS__
#include <Events.h>
#endif

#ifndef __ERRORS__
#include <Errors.h>
#endif

#ifndef __SCRAP__
#include <Scrap.h>
#endif

#ifndef __OSUTILS__
#include <OSUtils.h>
#endif
#endif

#include "macdefs.h"

extern void doMessage(short);

#define __UNDOACTION__

/*--------------------------- Types ----------------------------*/
typedef	struct LongRect
{
	long	top,left,bottom,right;
} LongRect;


typedef	struct LongPoint
{
	long	h,v;
} LongPoint;

typedef pascal Boolean (*TE32KProcPtr)(void);

typedef	struct TE32KRec
{
	LongRect			destRect;
	LongRect			viewRect;
	short				lineHeight;
	short				fontAscent;
	LongPoint			selPoint;
	long				selStart;
	long				selEnd;
#if ASCONSOLE
	long				consolePos; 
#endif
	short				active;
	TE32KProcPtr		clikLoop;
	long				clickTime;
	long				clickLoc;
	short				clikStuff;
	long				caretTime;
	short				caretState;
	long				teLength;
	Handle				hText;
	short				txFont;
	char				txFace;
	short				txMode;
	short				txSize;
	short				tabWidth;
	short				tabChars;
	short				maxLineWidth;
	Boolean				crOnly;
	Boolean				wrapToLength;
	Boolean				showInvisibles;
	Boolean				autoIndent;
	RgnHandle			selRgn;
	GrafPtr			 	inPort;
	long				nLines;
	long				undoStart;
	long				undoEnd;
#if MARKS
	long				undoDelta;
#endif
	Handle				undoBuf;
	short				resetUndo;
	short				theCharWidths[256];
#ifdef __PPCC__
	long				lineStarts[1];
#else
	long				lineStarts[];
#endif
	
} 	TE32KRec,*TE32KPtr,**TE32KHandle;
	
void			SetLongRect (LongRect *,long,long,long,long);
void			LongRectToRect (LongRect *,Rect *);
void			RectToLongRect (Rect *,LongRect *);
void    		OffsetLongRect (LongRect *, long, long);

void			TE32KInit (void);
TE32KHandle		TE32KNew (LongRect *,LongRect *);
void			TE32KDispose (TE32KHandle)  ;
void 			TE32KCalText (TE32KHandle)  ;
void			TE32KSetText (Ptr,long,TE32KHandle);
void			TE32KUseTextHandle (Handle,TE32KHandle);
Handle			TE32KGetText (TE32KHandle)  ;
void			TE32KUpdate (LongRect *,TE32KHandle);
void			TE32KScroll (long,long,TE32KHandle);
void			TE32KActivate (TE32KHandle)  ;
void			TE32KDeactivate (TE32KHandle)  ;
void			TE32KIdle (TE32KHandle)  ;
Boolean			TE32KKey (unsigned char,TE32KHandle,short);
short			TE32KClick (Point,unsigned char,TE32KHandle); /* changed return type to short */
void			TE32KSetSelect (long,long,TE32KHandle);

#if 0  /* 	BH: disabled because TE counterparts are obsolete since
			system 4.1 (!) */
OSErr			TE32KToScrap (void);
OSErr			TE32KFromScrap (void);
#endif

void			TE32KCopy (TE32KHandle);
void			TE32KCut (TE32KHandle);
void			TE32KDelete (TE32KHandle);
void			TE32KInsert (Ptr,long,TE32KHandle);
void			TE32KPaste (TE32KHandle);
Handle			TE32KScrapHandle (void);
long			TE32KGetScrapLen (void);
void			TE32KSetScrapLen (long);
void			TE32KGetPoint (long,LongPoint *,TE32KHandle);
long			TE32KGetOffset (LongPoint *,TE32KHandle);
void			TE32KSelView (TE32KHandle)  ;
void			TE32KSetFontStuff (short,short,short,short,TE32KHandle);

#if 0 /* BH: disabled because it does not do what it promises */
void			TE32KAutoView (char, TE32KHandle);
#endif

void			TE32KUndo (TE32KHandle);

#define isIdChar(c) (isalnum (c) || c == '_')

char islbracket(char c);
char isrbracket(char c);

#if ASCONSOLE
Boolean			TE32KIsEOF (TE32KHandle);
void			TE32KSetEOF (TE32KHandle);
#endif
