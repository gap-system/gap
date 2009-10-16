/****************************************************************************
**
*W  macte.c                     GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the text engine (a TextEdit replacement) for the built-in text editor.
**	
**	The text engine is based upon TE32K by Roy Wood. 
*/
#if !TARGET_API_MAC_CARBON
#include <AppleEvents.h>
#include <Balloons.h>
#include <files.h>
#include <Fonts.h>
#include <Gestalt.h>
#include <Lists.h>
#include <Menus.h>
#include <QuickDraw.h>
#include <Scrap.h>
#include <StandardFile.h>
#include <String.h>
#include <Sound.h>

#if OLDROUTINELOCATIONS  /* c2pstr */
	# include <Strings.h>
#else 
	#include <TextUtils.h>
#endif
#include <ToolUtils.h>
#include <Palettes.h>
#include <Printing.h>
#include <resources.h>   /* BH: changed */
#include <processes.h>   /* BH: changed */
#include <SegLoad.h>   /* BH: changed */
#include <Devices.h>   /* BH: changed */
#include <CType.h>
#include <ToolUtils.h>
#endif

#include "macdefs.h"
#include "macte.h"
#include "macedit.h"


/*--------------------------- Macros ----------------------------*/

#define Clip2Short(n) ((n)<-kMaxShort)? -kMaxShort:((n)>kMaxShort)? kMaxShort:n;
#define mClearCaret(h) if((**h).caretState) xorCaret(h)

char islbracket(char c) 
{
	if(c=='"') return '"';
	if(c=='\'') return '\'';
	if(c=='Œ') return '¹';  
	if(c=='³') return '²';  
	if(c=='(') return ')';
	if(c=='{') return '}';
	if(c=='[') return ']';
	if(c=='/') return '/';
	return 0;
}

char isrbracket(char c) 
{
	if(c=='"') return '"';
	if(c=='\'') return '\'';
	if(c=='¹') return 'Œ';  
	if(c=='²') return '³'; 
	if(c==')') return '(';
	if(c=='}') return '{';
	if(c==']') return '[';
	if(c=='/') return '/';
	return 0;
}

/* Some globals for TE32K */

long			TE32KAnchor = -1;
long			TE32KHPos = -1;
Boolean			TE32KTranslationMgrPresent = false;

static long		LineEndIndex (long,TE32KHandle);
static void		CalParagraph (long,TE32KHandle,long *,long *);
static long 	paraLines (long,TE32KHandle);
static void 	updateLine (long,TE32KHandle,short,LongRect *);
static void 	invertSelectRgn (TE32KHandle);
static void 	extendHilite(long,long,TE32KHandle);

static void 	makeSelectRgn (TE32KHandle);
static OSErr 	te32KCopy(TE32KHandle tH);

void			xorCaret (TE32KHandle);
long			indexToLine(long,TE32KHandle);
long			indexToParagraph(long,TE32KHandle);
void			positionView(TE32KHandle,long);

#if BEACHBALL
#include "Acurs.h"  
#endif

void TE32KSetFontStuff(short txFont,short txFace,short txMode,short txSize,TE32KHandle tH)
{
	register short		i;
	short				oldFont,oldFace,oldSize,oldMode;
	GrafPtr			oldPort;
	FontInfo			theFontInfo;


	(**tH).txFont = txFont;
	(**tH).txFace = txFace;
	(**tH).txMode = txMode;
	(**tH).txSize = txSize;
	
	GetPort(&oldPort);
	SetPort((**tH).inPort);

#if TARGET_CPU_PPC
	oldFont = GetPortTextFont ((**tH).inPort);
	oldFace = GetPortTextFace ((**tH).inPort);
	oldSize = GetPortTextSize ((**tH).inPort);
	oldMode = GetPortTextMode ((**tH).inPort);
#else
	oldFont = ((**tH).inPort)->txFont;
 	oldFace = ((**tH).inPort)->txFace;
 	oldSize = ((**tH).inPort)->txSize;
 	oldMode = ((**tH).inPort)->txMode;
#endif	

	TextFont((**tH).txFont);
	TextFace((**tH).txFace);
	TextSize((**tH).txSize);
	TextMode((**tH).txMode);
	
	
	for(i=0;i<256;i++)
		(**tH).theCharWidths[i] = CharWidth((unsigned char) i);
	if((**tH).tabChars)
		(**tH).tabWidth = (**tH).tabChars * (**tH).theCharWidths[' '];
	GetFontInfo(&theFontInfo);
	
	(**tH).lineHeight = theFontInfo.ascent + theFontInfo.descent + theFontInfo.leading;
	(**tH).fontAscent = theFontInfo.ascent;
	
	TextFont(oldFont);
	TextFace(oldFace);
	TextSize(oldSize);
	TextMode(oldMode);
	
	SetPort(oldPort);
}

void SetLongRect(LongRect *theLongRect,long left,long top,long right,long bottom)
{
	theLongRect->left = left;
	theLongRect->top = top;
	theLongRect->right = right;
	theLongRect->bottom = bottom;
}

void RectToLongRect(Rect *theRect,LongRect *theLongRect)
{
	theLongRect->left = (long) theRect->left;
	theLongRect->top = (long) theRect->top;
	theLongRect->right = (long) theRect->right;
	theLongRect->bottom = (long) theRect->bottom;
}

void LongRectToRect(LongRect *theLongRect,Rect *theRect)
{
	theRect->left=Clip2Short(theLongRect->left);
	theRect->top=Clip2Short(theLongRect->top);
	theRect->right=Clip2Short(theLongRect->right);
	theRect->bottom=Clip2Short(theLongRect->bottom);
}

void    OffsetLongRect(LongRect *theLongRect, long x, long y)
{
        theLongRect->left += x;
        theLongRect->top += y;
        theLongRect->right += x;
        theLongRect->bottom += y;
}

long indexToParagraph(long selIndex,TE32KHandle tH)
{
	long i;
	char *p;
	
	if(tH) {
		i = indexToLine(selIndex,tH);
		if(!(**tH).crOnly) {
			p = (*(**tH).hText)+(**tH).lineStarts[i]-1;
			while(i>0 && ISNEOL (*p)) {  /* BH: *p != RETURN && *p != LINEFEED replaced by ISNEOL (*p) */
				i--;
				p =(*(**tH).hText)+(**tH).lineStarts[i]-1;
			}
		}
		return i;
	}
	return 0;
}

long indexToLine(long selIndex,TE32KHandle tH)
{

	/* This is a binary search into the LineStarts Array. */
	
	register long	i,delta;

	if (tH) {
		if (selIndex<=0 || (**tH).nLines<=1 || (**tH).teLength<1)
			return 0;
		
		else if (selIndex >= (**tH).teLength)
			return (**tH).nLines - 1 ;
		
		else {
			i = delta = ((**tH).nLines) >> 1;
			
			delta = ((**tH).nLines) >> 1;
			if (delta < 1)
				delta = 1;
			
			while (delta > 0) {
				if (selIndex == (**tH).lineStarts[i])
					delta = 0;
				
				else if (selIndex > (**tH).lineStarts[i]) {
					if (selIndex < (**tH).lineStarts[i+1])
						delta = 0;
					
					else
						i += delta;
				} else
					i -= delta;
				
				if (delta) {
					delta >>= 1;
					
					if (delta < 1)
						delta = 1;
				}
			}
		}
		
		if (i < 0)
			i = 0;
		else if (i >= (**tH).nLines)
			i = (**tH).nLines - 1;
		
		return i;
	} else
		return 0;
}

void xorCaret(TE32KHandle tH)
{
	GrafPtr			oldPort;
	PenState		oldPenState;
	Point			selPt;
	RgnHandle		oldClipRgn;
	Rect			theClipRect;

	if (tH && (**tH).active && (**tH).selStart==(**tH).selEnd) {
		if ((**tH).selStart < 0) {
			DebugStr ("\p selection before start of test");
			(**tH).selStart = 0;
		}
		if ((**tH).selEnd > (**tH).teLength) {
			DebugStr ("\p selection past end of text");
			(**tH).selEnd = (**tH).teLength;
		}
/*		if (!(**tH).caretState && ((**tH).selStart < 0)  || (**tH).selEnd > (**tH).teLength)) {
			if (!(**tH).caretState)
				return;
		}
*/
			
		if(((**tH).selPoint.v - (**tH).fontAscent) < -kMaxShort)
			return;
			
		GetPort(&oldPort);
		SetPort((**tH).inPort);
		
		GetPenState(&oldPenState);
		oldClipRgn = NewRgn();
		GetClip(oldClipRgn);
		
		theClipRect.left = (short) ((**tH).viewRect.left);
		theClipRect.top = (short) ((**tH).viewRect.top);
		theClipRect.right = (short) ((**tH).viewRect.right);
		theClipRect.bottom = (short) ((**tH).viewRect.bottom);
		
		ClipRect(&theClipRect);
		
		PenNormal();
		
		PenMode(patXor);
		selPt.h = Clip2Short((**tH).selPoint.h);
		selPt.v = Clip2Short((**tH).selPoint.v);
				
		MoveTo(selPt.h - 1,selPt.v);
		Line(0,-(**tH).fontAscent);
		
		(**tH).caretTime = TickCount() + GetCaretTime();
		(**tH).caretState = !(**tH).caretState;
		
		SetClip(oldClipRgn);
		DisposeRgn(oldClipRgn);
		
		SetPenState(&oldPenState);
		SetPort(oldPort);
	}
}

void TE32KInit()
{
	PScrapStuff sInfo;
	OSErr err;
	long response;

#if !TARGET_API_MAC_CARBON
	sInfo = InfoScrap();
	if (sInfo->scrapState < 0)
		ZeroScrap (); /* initialize scrap if necessary */
#endif
	err = Gestalt (gestaltTranslationAttr, &response);
	TE32KTranslationMgrPresent = (err == noErr 
		&& response & (1 << gestaltTranslationMgrExists));
	TE32KHPos = TE32KAnchor = -1;
}

TE32KHandle TE32KNew(LongRect *destRect,LongRect *viewRect)
{
	TE32KHandle		newTE32KHandle;
	Handle			hText;
	GrafPtr			activePort;
	FontInfo		theFontInfo;
	LongPoint		selPt;

	newTE32KHandle = (TE32KHandle)NEWHANDLE((long) sizeof(TE32KRec) + (long) sizeof(long)*EXTRALINESTARTS);
	if (MEMERROR() || newTE32KHandle==NULL) {
		doMessage(1);
		return( (TE32KHandle)NULL);
	}
	
	hText = NEWHANDLE(EXTRATEXTBUFF);
	if (MEMERROR() || hText==NULL) {
		DisposeHandle((Handle) newTE32KHandle);
		doMessage(1);
		return ((TE32KHandle) NULL);
	}
	
	(**newTE32KHandle).destRect = *destRect;
	(**newTE32KHandle).viewRect = *viewRect;
	
	GetPort(&activePort);
	GetFontInfo(&theFontInfo);
	
	(**newTE32KHandle).lineHeight = theFontInfo.ascent + theFontInfo.descent + theFontInfo.leading;
	(**newTE32KHandle).fontAscent = theFontInfo.ascent;
	
	(**newTE32KHandle).selStart = 0;
	(**newTE32KHandle).selEnd = 0;
	
	(**newTE32KHandle).teLength = 0;
	(**newTE32KHandle).hText = hText;
	
#if ASCONSOLE
	TE32KSetEOF (newTE32KHandle);
#endif

#if TARGET_CPU_PPC
	(**newTE32KHandle).txFont = GetPortTextFont (activePort);
	(**newTE32KHandle).txFace = GetPortTextFace (activePort);
	(**newTE32KHandle).txMode = GetPortTextMode (activePort);
	(**newTE32KHandle).txSize = GetPortTextSize (activePort);
#else
 	(**newTE32KHandle).txFont = activePort->txFont;
 	(**newTE32KHandle).txFace = activePort->txFace;
 	(**newTE32KHandle).txMode = activePort->txMode;
 	(**newTE32KHandle).txSize = activePort->txSize;
#endif
	
	(**newTE32KHandle).inPort = activePort;
	
	(**newTE32KHandle).tabWidth = 24;
	(**newTE32KHandle).tabChars = 4;
	
/*	(**newTE32KHandle).maxLineWidth = kMaxShort;	*/

	(**newTE32KHandle).maxLineWidth = 75;
	
	(**newTE32KHandle).clikStuff = false;
	
	(**newTE32KHandle).crOnly = 0;
	(**newTE32KHandle).wrapToLength = 0;
	(**newTE32KHandle).autoIndent = 0;
	
	(**newTE32KHandle).showInvisibles = 0;
	
	(**newTE32KHandle).nLines = 1;
	(**newTE32KHandle).lineStarts[0] = 0;
	(**newTE32KHandle).lineStarts[1] = 0;
	
	(**newTE32KHandle).active = true;
	(**newTE32KHandle).caretState = false;
	(**newTE32KHandle).caretTime = TickCount();
	
	(**newTE32KHandle).clickTime = TickCount();
	(**newTE32KHandle).clickLoc = -1;
	
	TE32KGetPoint((**newTE32KHandle).selStart,&selPt,newTE32KHandle);
	
	(**newTE32KHandle).selPoint = selPt;
	
	(**newTE32KHandle).clikLoop = NULL;
	(**newTE32KHandle).selRgn = NULL;
	
	(**newTE32KHandle).undoBuf = NULL;
		
	(**newTE32KHandle).undoStart = 0;
	(**newTE32KHandle).undoEnd = 0;
#if MARKS
	(**newTE32KHandle).undoDelta = 0;
#endif
	
	(**newTE32KHandle).resetUndo = true;
	
	TE32KSetFontStuff((**newTE32KHandle).txFont,(**newTE32KHandle).txFace,(**newTE32KHandle).txMode,(**newTE32KHandle).txSize,newTE32KHandle);
	
	return( (TE32KHandle)newTE32KHandle);
}

void TE32KDispose(TE32KHandle tH)
{
	if (tH) {
		if ((**tH).hText)
			DisposeHandle((**tH).hText);
		if ((**tH).selRgn)
			DisposeRgn ((**tH).selRgn);
#ifdef __UNDOACTION__
		if((**tH).undoBuf)
			DisposeHandle((**tH).undoBuf);
#endif		
		DisposeHandle((Handle)tH);
	}
}

void TE32KCalText(TE32KHandle tH)
{
	register unsigned char	*charPtr;
	register long			charCount;
	register short			*theCharWidths,lineWidth,maxLineWidth;
	register unsigned char	ch;
	Boolean					atLineEnd,wrapToLength,crOnly,wrap;
	long					nLines,maxLineStarts,sizeTE32KHandle;
	unsigned char			*charBase;
	Point					cursorPt;
	short					rightSide,destLeftSide,maxRewind;
	unsigned char			*oldCharPtr;
	long					tabWidth,oldCharCount,tempOffset;

	if (tH) {
		(**tH).lineStarts[0] = 0;		/* assume the worst can happen and prepare for it */
		(**tH).lineStarts[1] = 0;
		(**tH).nLines = 1;
		
#if BEACHBALL
		ShowACurs();
#endif
		sizeTE32KHandle  = GetHandleSize((Handle) tH);
		maxLineStarts = (sizeTE32KHandle - (long) sizeof(TE32KRec))/(long) sizeof(long) - 2;
		
		wrapToLength = (**tH).wrapToLength;
		crOnly = (**tH).crOnly;
		maxLineWidth = (!(**tH).crOnly && wrapToLength)? (**tH).maxLineWidth : kMaxShort ;
		wrap = false;
		
		lineWidth = 0;
		nLines = 0;
		
		HLock ((**tH).hText);
		
		charBase = (unsigned char *) *((**tH).hText);
		charPtr = charBase;
		charCount = (**tH).teLength;
		
		
		if (charCount > 0) {
			rightSide = (short) ((**tH).destRect.right);
			destLeftSide = (short) ((**tH).destRect.left + 1);
			cursorPt.h = destLeftSide;
			tabWidth = (**tH).tabWidth;
			
			theCharWidths = (**tH).theCharWidths;
			
			while (charCount--) {
				ch = *charPtr++;
				lineWidth++;
				
				if(crOnly)
					atLineEnd =ISEOL(ch);
				else if(wrapToLength) {
					wrap = lineWidth > maxLineWidth;
					atLineEnd = wrap || ISEOL(ch) ;
				} else {
					if (ch == TAB)
						cursorPt.h = destLeftSide + ((cursorPt.h - destLeftSide + tabWidth)/tabWidth)*tabWidth;
					else
						cursorPt.h += theCharWidths[ch];
					
					wrap = (ch != ' ' && cursorPt.h >= rightSide);	
					atLineEnd = wrap || ISEOL(ch); 
				}
				
				if (atLineEnd) {
#if BEACHBALL
					SpinACurs(0);
#endif
					if (wrap) {
						/* I should probably add a hook for custom word-breaking */
						
						maxRewind = charPtr - charBase - (**tH).lineStarts[nLines];
						oldCharPtr = charPtr;
						oldCharCount = charCount;
						
						charPtr--;
						charCount++;
						maxRewind--;
						
						while (*charPtr != ' ' && maxRewind > 0) {
							charPtr--;
							charCount++;
							maxRewind--;
						}
						
						if (maxRewind <= 0) {
							charPtr = oldCharPtr;
							charCount = oldCharCount;
						} else {
							charPtr++;
							charCount--;
						}
					}
					
					if (nLines >= maxLineStarts) {
						tempOffset = charPtr - charBase;
												
						sizeTE32KHandle = (long) sizeof(TE32KRec) + (long) sizeof(long)*(nLines + EXTRALINESTARTS);
						maxLineStarts = (sizeTE32KHandle - (long) sizeof(TE32KRec))/(long) sizeof(long) - 2;
						
						SetHandleSize((Handle) tH,sizeTE32KHandle);
						
						if (MEMERROR()) {
#if BEACHBALL
							HideACurs();
#endif
							HUnlock ((**tH).hText);
							doMessage(1);
							return;
						}
						
						charBase = (unsigned char *) *((**tH).hText);
						charPtr = charBase + tempOffset;
						theCharWidths = (**tH).theCharWidths;
					}
					
					(**tH).lineStarts[++nLines] = charPtr - charBase;
					
					cursorPt.h = destLeftSide;
					lineWidth = 0;
				}
			}
			
#if BEACHBALL
			HideACurs();
#endif
			if (nLines >= maxLineStarts) {
				sizeTE32KHandle = (long) sizeof(TE32KRec) + (long) sizeof(long)*(nLines + EXTRALINESTARTS);
				
				SetHandleSize((Handle) tH,sizeTE32KHandle);
				
				if (MEMERROR()) {
					doMessage(1);
					HUnlock ((**tH).hText);
					return;
				}
			}
			
			(**tH).lineStarts[++nLines] = charPtr - charBase;
			(**tH).nLines = nLines;
		}
	}
	HUnlock ((**tH).hText);
}

void TE32KUseTextHandle(Handle hText,TE32KHandle tH)
{
	LongPoint	selPt;
	long textLength;

	if (tH) {
		textLength = GetHandleSize(hText);

		if ((**tH).hText)
			DisposeHandle((**tH).hText);
				
		(**tH).hText = hText;
		(**tH).teLength = textLength;
		
		(**tH).selStart = textLength;
		(**tH).selEnd = textLength;

#if ASCONSOLE
		TE32KSetEOF (tH);
#endif
		
		TE32KCalText(tH);

		TE32KGetPoint((**tH).selStart,&selPt,tH);
		(**tH).selPoint = selPt;
	}
}

void TE32KSetText(Ptr textPtr,long textLength,TE32KHandle tH)
{
	Handle		hText;
	LongPoint	selPt;

	if (tH) {
		hText = NEWHANDLE(textLength + EXTRATEXTBUFF);
		
		if (MEMERROR() || hText==NULL) {
			doMessage(1);
			return;
		}
		
		if ((**tH).hText)
			DisposeHandle((**tH).hText);
		
		HLock(hText);
		BlockMove(textPtr,*hText,textLength);
		HUnlock(hText);
		
		(**tH).hText = hText;
		(**tH).teLength = textLength;
		
		(**tH).selStart = textLength;
		(**tH).selEnd = textLength;
#if ASCONSOLE
		TE32KSetEOF (tH);
#endif
		
		TE32KCalText(tH);

		TE32KGetPoint((**tH).selStart,&selPt,tH);
		(**tH).selPoint = selPt;
	}
}

Handle TE32KGetText(TE32KHandle tH) 
{
	Handle hText;
	
	if (tH) {
		hText = (**tH).hText;
		HandToHand(&hText);
		return hText;
	} else
		return NULL;
}

static void DrawSpecialChar (short * width, unsigned char ch)
{
	unsigned char newch;
	short diff;

	switch (ch) {
		case TAB: 		newch = '€'; break;
		case RETURN: 	newch = '¶'; break;
		case LINEFEED:	newch = '¬'; break;
		case ' ':		newch = '×'; break;
	default:
		newch = '¿';
	}
	DrawChar (newch);
	diff = width[ch] - width[newch];
	if (diff)
		Move (diff, 0);
	
}

void TE32KUpdate(LongRect *updateLongRect,TE32KHandle tH) 
{
	LongRect					tempLongRect;
	long						lineHeight;
	Rect						theClipRect,viewRect,updateRect;
	GrafPtr						oldPort,currentPort;
	RgnHandle					oldClipRgn;
	register unsigned char		*textPtr;
	register long				firstLine,lastLine,tmpLine, i,thisStart,nextStart,tabWidth;
	Point						cursorPt;
	short						oldFont,oldFace,oldSize,oldMode;
	short						rightSide,destLeftSide;
	LongPoint					selPt;
	unsigned char				oldCaretState;
	Point						pnLoc;
	
	if (tH && (**tH).inPort) {
		tempLongRect = (**tH).viewRect;
		LongRectToRect(&tempLongRect,&viewRect);
		lineHeight = (**tH).lineHeight;

		tempLongRect = *updateLongRect;
		LongRectToRect(updateLongRect,&updateRect);
		
		if (SectRect(&viewRect,&updateRect,&theClipRect)) {
			GetPort(&oldPort);
			currentPort = (**tH).inPort;
			SetPort(currentPort);
			
			oldClipRgn = NewRgn();
			GetClip(oldClipRgn);

			ClipRect (&theClipRect);

#if DEBUG_UPDATE
			FillRgn (oldClipRgn, &qd.ltGray);
#endif
			
			oldCaretState = (**tH).caretState;
			
			if ((**tH).selStart == (**tH).selEnd && oldCaretState)
				xorCaret(tH);
			
			firstLine = ((long) theClipRect.top - (**tH).destRect.top)/lineHeight;
			lastLine = ((long) theClipRect.bottom - (**tH).destRect.top - 1)/lineHeight;
			
			if (firstLine < 0)
				firstLine = 0;
			
			if (lastLine >= (**tH).nLines)
				lastLine = (**tH).nLines - 1;
			
			if (firstLine > lastLine)
				lastLine = firstLine;
			
			tmpLine = firstLine + ((**tH).viewRect.bottom - (**tH).viewRect.top)/lineHeight - 1;
			if (tmpLine < lastLine)
				lastLine = tmpLine; /* never draw partial line at the bottom of the window */
			
			EraseRect(&theClipRect);

			if (firstLine < (**tH).nLines && (**tH).teLength > 0) {
				rightSide = theClipRect.right;
				destLeftSide = (short) (**tH).destRect.left + 1;
				cursorPt.h = destLeftSide;
				cursorPt.v = (short) ((**tH).destRect.top + firstLine * lineHeight + (long) (**tH).fontAscent);
				
#if TARGET_CPU_PPC
				oldFont = GetPortTextFont ((**tH).inPort);
				oldFace = GetPortTextFace ((**tH).inPort);
				oldSize = GetPortTextSize ((**tH).inPort);
				oldMode = GetPortTextMode ((**tH).inPort);
#else
 				oldFont = ((**tH).inPort)->txFont;
 				oldFace = ((**tH).inPort)->txFace;
 				oldSize = ((**tH).inPort)->txSize;
 				oldMode = ((**tH).inPort)->txMode;
#endif
				TextFont((**tH).txFont);
				TextFace((**tH).txFace);
				TextSize((**tH).txSize);
				TextMode((**tH).txMode);
				
				HLock((**tH).hText);
				
				textPtr = (unsigned char *) *((**tH).hText);
				tabWidth = (long) (**tH).tabWidth;
				
				while (firstLine <= lastLine) {
					thisStart = (**tH).lineStarts[firstLine];
					i = thisStart;
					
					nextStart = (**tH).lineStarts[firstLine+1];
					
					if (nextStart > thisStart && ISEOL(textPtr[nextStart-1]))
						nextStart--;
					
					MoveTo(cursorPt.h,cursorPt.v);
					
					if((**tH).showInvisibles) {
						while (thisStart < nextStart) {
							while (i<nextStart && textPtr[i]>=0x20 && !isspace(textPtr[i]))
								i++;

							if (i > thisStart)
								DrawText(&(textPtr[thisStart]),0,(short) (i - thisStart));
							
							if(i<nextStart) {
								if (textPtr[i]==TAB) {
									DrawSpecialChar((**tH).theCharWidths, TAB);
									GetPortPenLocation (currentPort, &pnLoc);
									MoveTo(destLeftSide + ((pnLoc.h - destLeftSide + tabWidth)/tabWidth)*tabWidth,pnLoc.v);
								} 
								else 
									DrawSpecialChar((**tH).theCharWidths, textPtr[i]);
								i++;
							}
							
							thisStart = i;
							
							GetPortPenLocation (currentPort, &pnLoc);
							if (pnLoc.h > theClipRect.right)
								thisStart = nextStart;
						}
						if(i<(**tH).teLength && textPtr[i]=='\n')
							DrawChar('¬');
					} else {
						while (thisStart < nextStart) {
							while (i<nextStart && textPtr[i]!=TAB)
								i++;
							
							if (i > thisStart)
								DrawText(&(textPtr[thisStart]),0,(short) (i - thisStart));
							
							if (i<nextStart && textPtr[i]==TAB) {
								GetPortPenLocation (currentPort, &pnLoc);
								MoveTo(destLeftSide + ((pnLoc.h - destLeftSide + tabWidth)/tabWidth)*tabWidth,pnLoc.v);
								i++;
							}
							
							thisStart = i;
							
							GetPortPenLocation (currentPort, &pnLoc);
							if (pnLoc.h > theClipRect.right)
								thisStart = nextStart;
						}
					}
					firstLine++;
					cursorPt.v += lineHeight;
				}
				
				HUnlock((**tH).hText);
				
				TextFont(oldFont);
				TextFace(oldFace);
				TextSize(oldSize);
				TextMode(oldMode);
			}
			
			if ((**tH).selStart < (**tH).selEnd)
				invertSelectRgn(tH);		/*  show the selection */
			
			else {
				TE32KGetPoint((**tH).selStart,&selPt,tH);
				(**tH).selPoint = selPt;
				
				if (oldCaretState)
					xorCaret(tH);
			}
			
			SetClip(oldClipRgn);
			DisposeRgn(oldClipRgn);

			SetPort(oldPort);
		}
	}
}

void TE32KScroll(long horiz,long vert,TE32KHandle tH)
{
	LongRect	updateLongRect;
	Rect		scrollRect;
#if TARGET_CPU_PPC
	Rect tempRect;
#endif	
	RgnHandle	updateRgn, clipRgn;
	GrafPtr		oldPort;
	LongPoint	selPt;
	
	if (tH && (**tH).inPort && (horiz || vert)) {
		GetPort(&oldPort);
		SetPort((**tH).inPort);
		
		(**tH).destRect.left += horiz;
		(**tH).destRect.right += horiz;
		(**tH).selPoint.h += horiz;
		
		(**tH).destRect.top += vert;
		(**tH).destRect.bottom += vert;
		(**tH).selPoint.v += vert;
		if((**tH).selRgn && (**tH).selStart!=(**tH).selEnd)
			makeSelectRgn (tH);
				/* BH: replaced OffsetRgn((**tH).selRgn,(short) horiz,(short) vert); */
		
		selPt = (**tH).selPoint;
		
		scrollRect.left = (**tH).viewRect.left;
		scrollRect.top = (**tH).viewRect.top;
		scrollRect.right = (**tH).viewRect.right;
		scrollRect.bottom = (**tH).viewRect.bottom; 
		
		if (horiz < (scrollRect.right-scrollRect.left) &&
				-horiz < (scrollRect.right-scrollRect.left) &&
				vert < scrollRect.bottom - scrollRect.top&&
				-vert <  scrollRect.bottom - scrollRect.top) {
			updateRgn = NewRgn();
					
			ScrollRect(&scrollRect,(short) horiz,(short) vert,updateRgn);
			
#if TARGET_CPU_PPC
			GetRegionBounds (updateRgn, &tempRect);
			updateLongRect.left = tempRect.left;
			updateLongRect.top = tempRect.top;
			updateLongRect.right = tempRect.right;
			updateLongRect.bottom = tempRect.bottom;
#else
			updateLongRect.left = (**updateRgn).rgnBBox.left;
			updateLongRect.top = (**updateRgn).rgnBBox.top;
			updateLongRect.right = (**updateRgn).rgnBBox.right;
			updateLongRect.bottom = (**updateRgn).rgnBBox.bottom;
#endif

			clipRgn = NewRgn ();
			GetClip (clipRgn);
			SectRgn (clipRgn, updateRgn, updateRgn);
			SetClip (updateRgn);

#if DEBUG_UPDATE
			FillRgn (updateRgn, &qd.gray);
#endif
			TE32KUpdate(&updateLongRect,tH);

			SetClip (clipRgn);

			DisposeRgn(updateRgn);
			DisposeRgn (clipRgn);
							
			mClearCaret(tH);
			
			(**tH).selPoint = selPt;
			
			xorCaret(tH);
		} else {
			LongRectToRect (&(**tH).viewRect, &scrollRect);
			InvalRect (&scrollRect);
#if 0
			updateLongRect = (**tH).viewRect;
			
			TE32KUpdate(&updateLongRect,tH);
			
			mClearCaret(tH);
#endif
			
			(**tH).selPoint = selPt;
			
			xorCaret(tH);
		}
		
		SetPort(oldPort);
	}
}

void TE32KActivate(TE32KHandle tH)
{
	if (tH && !((**tH).active)) {
		invertSelectRgn(tH);		/*  Remove frame */
		(**tH).active = true;
		(**tH).caretState = false;
		TE32KAnchor = -1;
		invertSelectRgn(tH);		/*  Hilite selection */
	}
}

void TE32KIdle(TE32KHandle tH)
{
	if (tH && ((**tH).selStart == (**tH).selEnd) && (**tH).active && TickCount() >= (**tH).caretTime) 
		xorCaret(tH);
}

void TE32KDeactivate(TE32KHandle tH)
{
	if (tH && (**tH).active) {
		invertSelectRgn(tH);		/*  Remove hilite */
		(**tH).active = false;
		invertSelectRgn(tH);		/*  Add frame */
	}
}

void TE32KGetPoint(long selIndex,LongPoint *selPt,TE32KHandle tH)
{
	register unsigned char	*textPtr;
	register short			*theCharWidths;
	register long			i,thisStart,tabWidth;
	long					x,destLeftSide;
	LongPoint				origPt;
	short					clikStuff;

	if (tH) {
		if (selIndex<=0 || (**tH).teLength<1) {
			selPt->h = (**tH).destRect.left + 1;
			selPt->v = (**tH).destRect.top + (**tH).fontAscent;
			(**tH).clikStuff = false;
			return;
		}
		
		clikStuff = (**tH).clikStuff;
		(**tH).clikStuff = false;
		
		origPt = *selPt;
		
		i = indexToLine(selIndex,tH);
		
		selPt->v = (**tH).destRect.top + ((**tH).lineHeight * i) + (**tH).fontAscent;
		
		if (!(**tH).crOnly && clikStuff && i > 0 && selIndex == (**tH).lineStarts[i]) {
			i--;
			selPt->v -= (**tH).lineHeight;
		} else if (selIndex < (**tH).lineStarts[i] || (selIndex == (**tH).lineStarts[i] && i < 1)) {
			selPt->h = (**tH).destRect.left + 1;
			return;
		}
		
		HLock((**tH).hText);
		
		textPtr = (unsigned char *) *((**tH).hText);
		
		destLeftSide = (**tH).destRect.left + 1;
		x = destLeftSide;
		
		theCharWidths = (**tH).theCharWidths;
		
		if (ISNEOL(textPtr[selIndex-1])) {
			tabWidth = (**tH).tabWidth;
			
			for(thisStart = (**tH).lineStarts[i];thisStart < selIndex;thisStart++) {				
				if (*(textPtr+thisStart) == TAB)
					x = destLeftSide + ((x - destLeftSide + tabWidth)/tabWidth)*tabWidth;
				else
					x += *(theCharWidths + *(textPtr+thisStart));
			}
		}
		
		HUnlock((**tH).hText);
		
		selPt->h = x;
	}
}

long	TE32KGetOffset(LongPoint *selPt,TE32KHandle tH)
{
	register unsigned char	*textPtr;
	register short			*theCharWidths;
	register long			i,delta,firstChar,lastChar,tabWidth;
	unsigned char			done;
	long					x,y,selIndex,horiz,destLeftSide;

	if (tH) {
		if ((**tH).teLength < 1)
			return 0;
		
		horiz = selPt->h;
		
		y = selPt->v - (**tH).destRect.top;
		
		i = y / (long) (**tH).lineHeight;
		
		if (i < 0)
			return 0;
		
		if (i >= (**tH).nLines)
			return((**tH).teLength);
		
		theCharWidths = (**tH).theCharWidths;
		
		HLock((**tH).hText);
		
		textPtr = (unsigned char *) *((**tH).hText);
		
		destLeftSide = (**tH).destRect.left + 1;
		x = destLeftSide;
		delta = 0;
		
		firstChar = (**tH).lineStarts[i];
		lastChar = (**tH).lineStarts[i+1];
		
		tabWidth = (long) (**tH).tabWidth;
		
		if (firstChar<lastChar && x+delta<horiz) {
			done = false;
		
			while (!done) {
				if (textPtr[firstChar] != TAB)
					delta = theCharWidths[textPtr[firstChar]];
				else
					delta = (destLeftSide + ((x - destLeftSide + tabWidth)/tabWidth)*tabWidth) - x;
				
				firstChar++;
				
				if (firstChar >= lastChar) {	
					if (ISEOL(textPtr[lastChar - 1]))
						selIndex = lastChar - 1;
					else
						selIndex = lastChar;
					
					done = true;
				} else if (x+delta >= horiz) {
					if (horiz >= x + (delta >> 1))
						selIndex = firstChar;
					else
						selIndex = --firstChar;
					
					done = true;
				} else
					x += delta;
			}
		} else
			selIndex = firstChar;

		HUnlock((**tH).hText);
		
		return selIndex;
	}
	return 0;
}

#include <LowMem.h>  /*BH: inserted for LMGetHiliteMode, LMSetHiliteMode */

static void invertSelectRgn(TE32KHandle tH)
{
	Rect		viewRect;
	RgnHandle	viewRgn;
	GrafPtr		oldPort;
	UInt8		hiliteMode; /*BH: inserted */

	if(tH) {			
		if((**tH).selStart == (**tH).selEnd) {
			if((**tH).active && (**tH).caretState)
				xorCaret(tH);		/*===== eventually make this a dashed line ======*/
		} else if( (**tH).selRgn) {
			viewRect.left = (**tH).viewRect.left;
			viewRect.top = (**tH).viewRect.top;
			viewRect.right = (**tH).viewRect.right;
			viewRect.bottom = (**tH).viewRect.bottom;
		
			GetPort(&oldPort);
			SetPort((**tH).inPort);
			viewRgn=NewRgn();
			RectRgn(viewRgn,&viewRect);
			SectRgn(viewRgn,(**tH).selRgn,viewRgn);
			if (!EmptyRgn(viewRgn)) {
				/*BH: replaced BitClr((void *)HiliteMode,pHiliteBit); */
				hiliteMode = LMGetHiliteMode ();
				BitClr(&hiliteMode,pHiliteBit);
				LMSetHiliteMode (hiliteMode);
				if((**tH).active)
					InvertRgn(viewRgn);
				else {
					PenSize(1,1);
					PenMode(patXor);
					FrameRgn(viewRgn);
				}
			}
			SetPort(oldPort);
			DisposeRgn(viewRgn);
		}
	}
}

static void extendHilite(long extStart,long extEnd,TE32KHandle tH)
{
	long 		firstLine,lastLine;
	Rect		viewRect,tR,theRect;
	LongPoint	selPt;
	RgnHandle	extRgn,tempRgn=0;
	GrafPtr		oldPort;
	long temp;
	UInt8	hiliteMode;  /*BH: need it; see below */
	
	if(tH && (**tH).active) {
		if((**tH).caretState)
			xorCaret(tH);
			
		if(extStart==extEnd)
			return;
		
		if(!(extRgn=NewRgn()))
			return;
			
		viewRect.left = (**tH).viewRect.left;
		viewRect.top = (**tH).viewRect.top;
		viewRect.right = (**tH).viewRect.right;
		viewRect.bottom = (**tH).viewRect.bottom;
		
		GetPort(&oldPort);
		SetPort((**tH).inPort);

		if (extStart > extEnd) {
			firstLine = extStart;
			extStart = extEnd;
			extEnd = firstLine;
		}
			
		firstLine = indexToLine(extStart,tH);
		lastLine = indexToLine(extEnd,tH);
		
		TE32KGetPoint(extStart,&selPt,tH);
		selPt.v -= (**tH).fontAscent;
		
		if(extStart<=(**tH).selStart)
			selPt.h--;
/* 		else if(*(*(**tH).hText+extStart)==NEWLINE) BH: RETURN replaced by NEWLINE, just in caseÉ */
		else if((selPt.h-viewRect.left)==1)
			selPt.h--;
		tR.left = Clip2Short(selPt.h);
		tR.top  = Clip2Short(selPt.v);
		
		/* frame the first line */
		if (firstLine != lastLine) {
			tR.right = Clip2Short (viewRect.right);
			tR.bottom = tR.top + (**tH).lineHeight;
		} else {
			TE32KGetPoint(extEnd,&selPt,tH);
			selPt.v -= (**tH).fontAscent;
			selPt.v += (**tH).lineHeight;
			if(extEnd<(**tH).selEnd)
				selPt.h--;
			tR.right = Clip2Short(selPt.h);
			tR.bottom = Clip2Short(selPt.v);
		}
		if (SectRect(&viewRect,&tR,&theRect)) {
			hiliteMode = LMGetHiliteMode ();
			BitClr(&hiliteMode,pHiliteBit);  /*BH: don't acces HiliteMode directly */
			LMSetHiliteMode (hiliteMode);
			InvertRect(&theRect);
		}
		RectRgn(extRgn,&tR);
		temp = GetHandleSize((Handle)extRgn);
		
		/* If there are middle lines, frame them. */
		
		if (lastLine > firstLine+1) {
			TE32KGetPoint(extEnd,&selPt,tH);
			
			tR.left = viewRect.left;
			tR.top = tR.bottom;
			tR.right = Clip2Short (viewRect.right);;
			
			selPt.v -= (**tH).fontAscent;
			
			tR.bottom = Clip2Short(selPt.v);
			
			selPt.v += (**tH).fontAscent;
			
			if (SectRect(&viewRect,&tR,&theRect)) {
				hiliteMode = LMGetHiliteMode ();
				BitClr(&hiliteMode,pHiliteBit);  /*BH: replaced HiliteMode */
				LMSetHiliteMode (hiliteMode);
				InvertRect(&theRect);
			}
			if(tempRgn=NewRgn()) {
				RectRgn(tempRgn,&tR);
				UnionRgn(extRgn,tempRgn,extRgn);
			}
			temp = GetHandleSize((Handle)extRgn);
		}
		/* If there is a last line, frame it. */
		
		if (lastLine > firstLine && extEnd > (**tH).lineStarts[lastLine]) {
			if (lastLine == firstLine+1) 
				TE32KGetPoint(extEnd,&selPt,tH);
			
			selPt.v -= (**tH).fontAscent;
			tR.top = Clip2Short(selPt.v);
			selPt.v += (**tH).lineHeight;
			tR.bottom = Clip2Short(selPt.v);
			tR.left = viewRect.left;
			if(extEnd<(**tH).selEnd)
				selPt.h--;
			tR.right = Clip2Short(selPt.h);
			
			if (SectRect(&viewRect,&tR,&theRect)) {
				hiliteMode = LMGetHiliteMode ();
				BitClr(&hiliteMode,pHiliteBit);  /*BH: replaced HiliteMode */
				LMSetHiliteMode (hiliteMode);
				InvertRect(&theRect);
			}
			if(!tempRgn)
				tempRgn=NewRgn();
			if(tempRgn) {
				RectRgn(tempRgn,&tR);
				UnionRgn(extRgn,tempRgn,extRgn);
			}
			temp = GetHandleSize((Handle)extRgn);
		}
		if(tempRgn)
			DisposeRgn(tempRgn);
		SetPort(oldPort);
		tempRgn=(**tH).selRgn;
		if(extStart<(**tH).selStart || extEnd>(**tH).selEnd) 
			UnionRgn(tempRgn,extRgn,tempRgn);
		else
			DiffRgn(tempRgn,extRgn,tempRgn);
		DisposeRgn(extRgn);
	}
}

static void makeSelectRgn(TE32KHandle tH)
{
	long		firstLine,lastLine;
	Rect		viewRect,tR;
	LongPoint	selPt;
	GrafPtr		oldPort;
	RgnHandle	selRgn;
	long temp;

	if (tH) {
		if((**tH).selRgn)
			SetEmptyRgn((**tH).selRgn);
		else
			(**tH).selRgn = NewRgn();
		if ((**tH).selStart == (**tH).selEnd) {
			TE32KGetPoint((**tH).selStart,&(**tH).selPoint,tH);
			return;
		}
		if(selRgn = (**tH).selRgn) {
			GetPort(&oldPort);
			SetPort((**tH).inPort);
			
			OpenRgn();
			viewRect.left = (**tH).viewRect.left;
			viewRect.top = (**tH).viewRect.top;
			viewRect.right = (**tH).viewRect.right;
			viewRect.bottom = (**tH).viewRect.bottom;
			
			if ((**tH).selStart > (**tH).selEnd) {
				firstLine = (**tH).selStart;
				(**tH).selStart = (**tH).selEnd;
				(**tH).selEnd = firstLine;
			}
			
			firstLine = indexToLine((**tH).selStart,tH);
			lastLine = indexToLine((**tH).selEnd,tH);
			TE32KGetPoint((**tH).selStart,&selPt,tH);
			selPt.v -= (**tH).fontAscent;
/* 			if ((**tH).selStart >= (**tH).lineStarts[firstLine]) */
				selPt.h--;
			tR.left = Clip2Short(selPt.h);
			tR.top  = Clip2Short(selPt.v); 
			
			/* frame the first line */
			if (firstLine != lastLine) {
 				tR.right = Clip2Short (viewRect.right);	
/* BH: was				tR.right = 2000;  */
				tR.bottom = tR.top + (**tH).lineHeight;
			} else {
				TE32KGetPoint((**tH).selEnd,&selPt,tH);
				selPt.v -= (**tH).fontAscent;
				selPt.v += (**tH).lineHeight;
				tR.right = Clip2Short(selPt.h);
				tR.bottom = Clip2Short(selPt.v);
			}
			FrameRect(&tR);
			
			/* If there are middle lines, frame them. */
			
			if (lastLine > firstLine+1) {
				TE32KGetPoint((**tH).selEnd,&selPt,tH);
				tR.left = viewRect.left;
				tR.top = tR.bottom;
 				tR.right = Clip2Short (viewRect.right);	
/* BH: was				tR.right = 2000;  */
				selPt.v -= (**tH).fontAscent;
				tR.bottom = Clip2Short(selPt.v);
				selPt.v += (**tH).fontAscent;
				FrameRect(&tR);
			}
			
			/* If there is a last line, frame it. */
			
			if (lastLine > firstLine && (**tH).selEnd > (**tH).lineStarts[lastLine]) {
				if (lastLine == firstLine+1) 
					TE32KGetPoint((**tH).selEnd,&selPt,tH);
				selPt.v -= (**tH).fontAscent;
				tR.top = Clip2Short(selPt.v);
				selPt.v += (**tH).lineHeight;
				tR.bottom = Clip2Short(selPt.v);
				tR.left = viewRect.left;
				tR.right = Clip2Short(selPt.h);
				FrameRect(&tR);
			}
			CloseRgn(selRgn);
			SetPort(oldPort);
			temp = GetHandleSize((Handle)selRgn);
		}
	}
}



short TE32KClick(Point startPoint, unsigned char extend, TE32KHandle tH)  /* return type changed to short */
{
	register long				i,selAnchor, selLast, teLength;
	register unsigned char		*s;
	unsigned char				lmatch=0,rmatch=0;
	short						cnt;
	LongPoint					selPt,tempPt;
	Point						mousePt;
	GrafPtr						oldPort;
	long						oldClickLoc, tokenStart, tokenEnd;
	unsigned long				time, delay;
	static short 				ClickLevel=0;
	Boolean						matching=false;

	if (tH && (**tH).active) {
		(**tH).resetUndo = true;
		TE32KHPos = TE32KAnchor = -1;
		teLength = (**tH).teLength;
		
		mClearCaret(tH);
		
		selPt.h = (long) startPoint.h;
		selPt.v = (long) startPoint.v;
		
		oldClickLoc = (**tH).clickLoc;
		
		i = TE32KGetOffset(&selPt,tH);
		i = (i < 0)? 0 : (i > teLength)? teLength : i;
		(**tH).clickLoc = i;
			
		ClickLevel = (teLength > 0 && oldClickLoc == i &&
						TickCount() < (**tH).clickTime + GetDblTime()) ? 
							ClickLevel+1 : 0 ;
	
		tokenStart=tokenEnd=i;
		
		HLock ((**tH).hText);
		s=(unsigned char *) *(**tH).hText;
		
		if(ClickLevel==1) {				/*  Selection method for double click: */
			if(isIdChar(*(s+tokenStart))) {	/*  Select a word	*/
				for(;tokenStart>0 && isIdChar(*(s+tokenStart-1));tokenStart--);			
				for(;tokenEnd<teLength && isIdChar(*(s+tokenEnd));tokenEnd++);
			} else if(rmatch=islbracket(lmatch=*(s+tokenStart))) {
				matching=true;
				for(tokenStart++,tokenEnd++,cnt=1;cnt;cnt--) {
					for(;tokenEnd<teLength && rmatch!=*(s+tokenEnd);tokenEnd++)
						if(*(s+tokenEnd)==lmatch) cnt++;
					if(cnt>1) tokenEnd++;
				}
			} else if(lmatch=isrbracket(rmatch=*(s+tokenStart))) {
				matching=true;
				for(cnt=1;cnt;cnt--) {
					for(tokenStart--;tokenStart>0 && lmatch!=*(s+tokenStart-1);tokenStart--)
						if(*(s+tokenStart-1)==rmatch) cnt++;
				}
			} else
				tokenEnd++;
		} else if(ClickLevel) {			/*  Selection method for triple click: */
			for(;tokenStart>0 && ISNEOL(*(s+tokenStart-1));tokenStart--) ;
			for(;tokenEnd<teLength && ISNEOL(*(s+tokenEnd));tokenEnd++) ;
			tokenEnd++;
		}
		HUnlock ((**tH).hText);
		
		tokenStart = (tokenStart<0)? 0 : tokenStart;
		tokenEnd = (tokenEnd>teLength)? teLength : tokenEnd;
		
		if(!ClickLevel) {
			GetPort(&oldPort);
			SetPort((**tH).inPort);
		}

		if(extend) {
			if (tokenEnd >= (**tH).selEnd) {
				selAnchor = (**tH).selStart;
				selLast = (**tH).selEnd;
			} else {
				selAnchor = (**tH).selEnd;
				selLast = (**tH).selStart;
			}
			goto DOHILITE;
		} else {
			if ((**tH).selStart != (**tH).selEnd) {
				invertSelectRgn(tH);										/*  Deselect */
				if((**tH).selRgn)
					SetEmptyRgn((**tH).selRgn);
			}
			
			(**tH).selStart = selAnchor = tokenStart;
			(**tH).selEnd = selLast = tokenEnd;
			makeSelectRgn(tH);
			
			(**tH).clikStuff = false;
			TE32KGetPoint(i,&selPt,tH);
			
			if ((**tH).crOnly)
				(**tH).selPoint = selPt;
			else {
				(**tH).clikStuff = true;
				TE32KGetPoint(i,&tempPt,tH);
				
				if ((selPt.h - startPoint.h)*(selPt.h - startPoint.h) + (selPt.v - startPoint.v)*(selPt.v - startPoint.v) <
					(tempPt.h - startPoint.h)*(tempPt.h - startPoint.h) + (tempPt.v - startPoint.v)*(tempPt.v - startPoint.v))
						(**tH).selPoint = selPt;
				else
						(**tH).selPoint = tempPt;
			}
			invertSelectRgn(tH);											/*  Hilite */
		}
		
		time = TickCount();
		while (StillDown()) {
			
			GetMouse(&mousePt);
			selPt.h = (long) mousePt.h;
			selPt.v = (long) mousePt.v;
			
			i = TE32KGetOffset(&selPt,tH);
			tokenStart=tokenEnd=i;
			teLength=(**tH).teLength;
			HLock ((**tH).hText);
			s=(unsigned char *) *(**tH).hText;
			
			if(ClickLevel==1) {				/*  Selection method for double click: */
				if(matching) {
					for(tokenStart++,cnt=1;cnt;cnt--) {
						for(;tokenStart>0 && lmatch!=*(s+tokenStart-1);tokenStart--)
							if(*(s+tokenStart-1)==rmatch) cnt++;
					}
					if(tokenStart>tokenEnd) tokenEnd=tokenStart;
					for(cnt=1;cnt;cnt--) {
						for(;tokenEnd<teLength && rmatch!=*(s+tokenEnd);tokenEnd++)
							if(*(s+tokenEnd)==lmatch) cnt++;
						if(cnt>1) tokenEnd++;
					}
				} else {
					for(;tokenStart>0 && isIdChar(*(s+tokenStart-1)); tokenStart--) ;			
					for(;tokenEnd<teLength && isIdChar(*(s+tokenEnd));tokenEnd++) ;
				}
			} else if(ClickLevel) {			/*  Selection method for triple click: */
				for(;tokenStart>0 && ISNEOL(*(s+tokenStart-1));tokenStart--) ;
				for(;tokenEnd<teLength && ISNEOL(*(s+tokenEnd));tokenEnd++) ;
				tokenEnd++;
			}
			HUnlock ((**tH).hText);

			tokenStart = (tokenStart<0)? 0 : tokenStart;
			tokenEnd = (tokenEnd>teLength)? teLength : tokenEnd;
		
 DOHILITE:
 			if(extend) {
				if (selLast >= selAnchor) {							/*  extending down in text */
					if (tokenEnd>selLast) {	
						extendHilite(selLast,tokenEnd,tH);			/*  extend selection */
						(**tH).selEnd = selLast = tokenEnd;
					} else if (tokenEnd>=selAnchor && tokenEnd<selLast) {
						extendHilite(tokenEnd,selLast,tH);			/*  shorten selection */
						(**tH).selEnd = selLast = tokenEnd;
					} else if (tokenStart<selAnchor && tokenEnd<selLast) {
						extendHilite(selAnchor,selLast,tH);			/*  extend selection in other direction, remove old hiliting */
						extendHilite(tokenStart,selAnchor,tH);			/* add new */
						(**tH).selStart = selLast = tokenStart;
						(**tH).selEnd = selAnchor;
					}
				} else {												/* extending up in text */
					if (tokenStart<selLast) {
						extendHilite(tokenStart,selLast,tH);			/* extend selection */
						(**tH).selStart = selLast = tokenStart;
					} else if (tokenStart<=selAnchor && tokenStart>selLast) {
						extendHilite(selLast,tokenStart,tH);			/* shorten selection 8? */
						(**tH).selStart = selLast = tokenStart;
					} else if (tokenEnd>selAnchor) {
						extendHilite(selLast,selAnchor,tH);		/*  extend selection in other direction, remove old hiliting */
						extendHilite(selAnchor,tokenEnd,tH);		/*  add new */
						(**tH).selStart = selAnchor;
						(**tH).selEnd = selLast= tokenEnd;
					}
				}
			} else {
				if(tokenEnd<=selLast && selLast<(**tH).selEnd) {
					extendHilite(selLast,(**tH).selEnd,tH);				/* deselect */
					(**tH).selEnd=selLast;
				} else if(tokenEnd > (**tH).selEnd ||
					(tokenEnd<(**tH).selEnd && tokenEnd>selLast)) {
					extendHilite((**tH).selEnd,tokenEnd,tH);			/* deselect */
					(**tH).selEnd=tokenEnd;
				}
				
				if(tokenStart>=selAnchor && selAnchor>(**tH).selStart) {
					extendHilite((**tH).selStart,selAnchor,tH);			/* Add to selection */
					(**tH).selStart=selAnchor;
				} else if(tokenStart < (**tH).selStart ||
					(tokenStart>(**tH).selStart && tokenStart<selAnchor)) {
					extendHilite(tokenStart,(**tH).selStart,tH);		/*  Add to selection */
					(**tH).selStart=tokenStart;
				}
			}
			/* 	BH: moved clikLoop procedure here because hopefully the selection is marked 
				correctly */
			if ((**tH).clikLoop)
				(*((**tH).clikLoop)) ();  
			delay = TickCount() - time;
			if (delay < 1 )
				Delay (1-delay, &time);
			else
				time = TickCount();
		}	/*  end while StillDown () */
		
		if(!ClickLevel) 
			SetPort(oldPort);
		(**tH).clickTime = TickCount();
	}
	return ClickLevel;
}

void TE32KSetSelect(long selStart,long selEnd,TE32KHandle tH)
{
	long teLength;
	
	if (tH) {
		if((**tH).selStart < (**tH).selEnd || (**tH).caretState)
			invertSelectRgn(tH);			/*  Deselect */
		if((**tH).selRgn)
			SetEmptyRgn((**tH).selRgn);
			
		teLength=(**tH).teLength;
		
		if(selStart>teLength) {
			selStart=teLength;
			selEnd=teLength;
		} else {
			if(selStart<0)
				selStart=0;
			
			if(selEnd<0)
				selEnd=selStart;
			else if(selEnd>teLength)
				selEnd=teLength;
		}
			
		if (selStart <= selEnd) {
			(**tH).selStart = selStart;
			(**tH).selEnd = selEnd;
		} else {
			(**tH).selStart = selEnd;
			(**tH).selEnd = selStart;
		}
		makeSelectRgn(tH);
		invertSelectRgn(tH);				/*  Hilite new selection */
		
		TE32KHPos = TE32KAnchor = -1;
	}
}


#if 0  /* TEToScrap and TEFromScrap obsolete since system 4.1(!) */
Handle	TE32KScrapHandle()
{
	return(TE32KScrpHandle);
}

long	TE32KGetScrapLen()
{
	return(TE32KScrpLength);
}

void TE32KSetScrapLen(long newLength)
{
	TE32KScrpLength = newLength;
}


OSErr TE32KToScrap(void)
{
	OSErr err;

	if (TE32KScrpHandle && TE32KScrpLength > 0) {
		if ((err = ZeroScrap()) != noErr)
			return(err);

		HLockHi(TE32KScrpHandle);

		if ((err = PutScrap(TE32KScrpLength,'TEXT',(Ptr) *TE32KScrpHandle)) != noErr)
			return(err);

		HUnlock(TE32KScrpHandle);

		return(noErr);
	}
	
	return(noScrapErr);
}

OSErr TE32KFromScrap(void)
{
	long offset;
	PScrapStuff sInfo;
	long len;

	sInfo = InfoScrap();
	if (TE32KScrpHandle && (len = GetScrap(0,'TEXT',&offset)) > 0) {
		TE32KScrpLength = GetScrap(TE32KScrpHandle,'TEXT',&offset);
		
		if (TE32KScrpLength > 0)
			return(noErr);
		
		else if (TE32KScrpLength == 0)
			return(noTypeErr);
		
		else
			return(TE32KScrpLength);
	}
	
	if (TE32KScrpHandle == NULL)
		return(noScrapErr);
	
	else
		return((OSErr)len);
}
#endif

static OSErr te32KCopy(TE32KHandle tH)
{
	OSErr err;

	if (tH && (**tH).selStart < (**tH).selEnd) {
		if ((err = ZeroScrap()) == noErr) {
	
			HLock((**tH).hText);

			err = PutScrap((**tH).selEnd - (**tH).selStart,'TEXT', *((**tH).hText) + (**tH).selStart);

			HUnlock((**tH).hText);
		}
			
		if (err)
			return err;
	} 
	return noErr;
}


void TE32KCopy(TE32KHandle tH)
{
	OSErr err;

	if ((err = te32KCopy (tH)) != noErr)	
		if (err == memFullErr)
			doMessage (2);
		else
			doDiagnosticMessage (13, err);
}

void TE32KCut(TE32KHandle tH)
{
	if (tH && te32KCopy(tH) == noErr)
		TE32KDelete(tH);
}

#ifdef __UNDOACTION__

/*-------------------------------------------------------------------
	Undo works by replacing the selection bounded by undoStart and
	undoEnd with the contents of the undo buffer. A key point is 
	that since (**tH).undoBuf is nulled before TE32KDelete is called,
	the deleted selection is saved in a new undo buffer. The new
	selection is the length of the undo buffer.
	
	Operations that are to be undone need to keep the undoBuf
	properly filled, and undoStart and undoEnd correct. 
--------------------------------------------------------------------*/

void TE32KUndo(TE32KHandle tH)
{
	Handle undoH;
	long len;
	
	if(tH) {
		undoH = (**tH).undoBuf;
		(**tH).undoBuf=0;
		if((**tH).undoStart<(**tH).undoEnd) {
			TE32KSetSelect((**tH).undoStart,(**tH).undoEnd,tH);
			TE32KDelete(tH);
		} else {
/* 			(**tH).undoStart==(**tH).undoEnd;	*/
			TE32KSetSelect((**tH).undoEnd,(**tH).undoEnd,tH);
		}
		if(undoH) {
			HLock(undoH);
			TE32KInsert(*undoH,len=GetHandleSize(undoH),tH);
			HUnlock(undoH);
			DisposeHandle(undoH);
			TE32KSetSelect((**tH).selEnd-len,(**tH).selEnd,tH);
		}
		(**tH).resetUndo=true;
	}
}

#endif

void TE32KDelete(TE32KHandle tH)
{
	LongRect			updateRect;
	register long		*theLine,*otherLine,theLineStart,i,delta;
	long				firstLine,lastLine;
	Rect				tempRect;
	RgnHandle			updateRgn;
	GrafPtr				oldPort;

	if (tH && (**tH).hText && (**tH).selStart < (**tH).selEnd) {

		delta = (**tH).selEnd - (**tH).selStart;
		
#ifdef __UNDOACTION__
		if((**tH).undoBuf)
			DisposeHandle((**tH).undoBuf);
		(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
		(**tH).undoBuf=NEWHANDLE(delta);
		(**tH).resetUndo = false;
#if MARKS
		(**tH).undoDelta = 0;
#endif
		if (MEMERROR() || (**tH).undoBuf==NULL) {
			(**tH).undoBuf = 0;
			if (!doConfirmDialog(7, "\p"))
				return;
		} else {
			HLock((**tH).undoBuf);
			HLock((**tH).hText);
			BlockMove(*((**tH).hText) + (**tH).selStart,*(**tH).undoBuf,delta);
			HUnlock((**tH).hText);
			HUnlock((**tH).undoBuf);
		}
#endif
		invertSelectRgn(tH);		/*  Deselect */
		if((**tH).selRgn)
			SetEmptyRgn((**tH).selRgn);
			
		firstLine = indexToLine((**tH).selStart,tH);
		lastLine = indexToLine((**tH).selEnd,tH);
		
		updateRect = (**tH).viewRect;
		updateRect.top = (**tH).destRect.top + (firstLine + 1) * (**tH).lineHeight;
		LongRectToRect(&updateRect,&tempRect);
		
		GetPort(&oldPort);
		SetPort((**tH).inPort);
				
		updateRgn = NewRgn();
		ScrollRect(&tempRect,0,-(**tH).lineHeight * (lastLine - firstLine),updateRgn);
#if TARGET_CPU_PPC
		GetRegionBounds (updateRgn, &tempRect);
#else
		tempRect = (**updateRgn).rgnBBox;
#endif
		DisposeRgn(updateRgn);
		
		SetPort(oldPort);
				
		HLock((**tH).hText);

		if ((**tH).selEnd != (**tH).teLength) {
			BlockMove(*((**tH).hText) + (**tH).selEnd,*((**tH).hText) + (**tH).selStart,(**tH).teLength - (**tH).selEnd);
		}
		HUnlock((**tH).hText);
		
		theLine = &((**tH).lineStarts[firstLine + 1]);
		otherLine = &((**tH).lineStarts[lastLine + 1]);
		i = (**tH).nLines - lastLine;
		
		while (i--) {
			theLineStart = *(otherLine++);
			theLineStart -= delta;
			*(theLine++) = theLineStart;
		}
		
		(**tH).teLength -= delta;
		(**tH).selEnd = (**tH).selStart;
#if ASCONSOLE
		if ((**tH).consolePos > (**tH).selStart) {
			if ((**tH).consolePos >= (**tH).selEnd)
				(**tH).consolePos -= delta;
			else
				(**tH).consolePos = (**tH).selStart;
		}
#endif
		(**tH).nLines -= (lastLine - firstLine);
		
		RectToLongRect(&tempRect,&updateRect);
		TE32KUpdate(&updateRect,tH);	/* update scrolled stuff */
		
		updateLine(firstLine,tH,true,0);
	}
}

void TE32KInsert(Ptr textPtr,register long textLength,TE32KHandle tH)
{
	register long				*theLine,*otherLine,i,numCRs;
	long						firstLine,teLength,maxLineStarts,sizeTE32KHandle, delta;
	register unsigned char		*charPtr,*charBase;
	RgnHandle					updateRgn;
	LongRect					updateRect;
	Rect						tempRect;
#if TARGET_CPU_PPC
	Rect						r;
#endif
	GrafPtr						oldPort;
	Handle						newText;

	if (tH && textPtr && textLength > 0) {
		if ((**tH).selStart < (**tH).selEnd) {
			delta = (**tH).selEnd - (**tH).selStart;
			invertSelectRgn(tH);		/*  Deselect */
			if((**tH).selRgn)
				SetEmptyRgn((**tH).selRgn);
		} else
			delta = 0;

#if 0  /* BH: disabled because TE32KKey does not work if window is inactive */
		if (textLength == 1) {
			if (ISEOL (*((unsigned char *) textPtr)))   /*BH: otherwise problems inserting a single '\n' */
				TE32KKey (RETURN, tH, 0);
			else
				TE32KKey(*((unsigned char *) textPtr),tH,0);
		} else 
#endif
		{
			firstLine = indexToLine((**tH).selStart,tH);
			
			teLength = (**tH).teLength + textLength;
			
			if (!(**tH).hText || GetHandleSize((**tH).hText) < teLength) {  /* BH: inserted !(**tH).hText || */
				SetHandleSize((**tH).hText,teLength + EXTRATEXTBUFF);
				
				if (MEMERROR() || GetHandleSize((**tH).hText) < teLength + EXTRATEXTBUFF) {
					newText=NEWHANDLE(teLength + EXTRATEXTBUFF);
					if(!newText) {
						doMessage(1);
						return;
					}
					HLock((**tH).hText);
					HLock(newText);
					
					BlockMove(*((**tH).hText),*newText,GetHandleSize((**tH).hText));
					
					HUnlock((**tH).hText);
					HUnlock(newText);
					DisposeHandle((**tH).hText);
					(**tH).hText=newText;
				}
			}
			
			HLock((**tH).hText);
			
#ifdef __UNDOACTION__

			(**tH).undoStart = (**tH).selStart;
			(**tH).undoEnd = (**tH).selStart + textLength;

#endif
			if ((**tH).teLength - (**tH).selStart)
				BlockMove(*((**tH).hText) + (**tH).selStart, *((**tH).hText) + (**tH).selStart + textLength, (**tH).teLength - (**tH).selStart);
			
			BlockMove(textPtr,*((**tH).hText) + (**tH).selStart,textLength);
			
			
			i = textLength;
			numCRs = 0;
			charPtr = (unsigned char *) textPtr;
			
			while (i--) {
				if (ISEOL(*charPtr))
					numCRs++;
				
				charPtr++;
			}
			
			
			if (numCRs) {
				sizeTE32KHandle  = GetHandleSize((Handle) tH);
				maxLineStarts = (sizeTE32KHandle - (long) sizeof(TE32KRec))/(long) sizeof(long) - 2;
				
				if ((**tH).nLines + numCRs >= maxLineStarts) {
					sizeTE32KHandle = (long) sizeof(TE32KRec) + (long) sizeof(long)*((**tH).nLines + numCRs + EXTRALINESTARTS);
					maxLineStarts = (sizeTE32KHandle - (long) sizeof(TE32KRec))/(long) sizeof(long) - 2;
					
					SetHandleSize((Handle) tH,sizeTE32KHandle);
					
					if (MemError()) {
						doMessage(1);
						HUnlock((**tH).hText);
						return;
					}
				}
				
				theLine = &((**tH).lineStarts[(**tH).nLines]);
				otherLine = &((**tH).lineStarts[(**tH).nLines + numCRs]);
				i = (**tH).nLines - firstLine;
				
				while (i--)
					*(otherLine--) = *(theLine--) + textLength;
				
				
			/* charPtr, charBase only used in this block so we don't have to lock (**tH).htext */
				charPtr = (unsigned char *) (*((**tH).hText) + (**tH).selStart) ;
				charBase = (unsigned char *) *((**tH).hText);
				theLine = &((**tH).lineStarts[firstLine + 1]);
				i = numCRs;
				
				while (i--) {
					while (ISNEOL(*charPtr))
						charPtr++;
					
					charPtr++;
					
					*theLine++ = charPtr - charBase;
				}
			/* charPtr, charBase not used after this line, so we don't have to lock (**tH).htext */
				
			} else {
				theLine = &((**tH).lineStarts[firstLine + 1]);
				i = (**tH).nLines - firstLine;
				
				while (i--)
					*(theLine++) += textLength;
			}
			
#if ASCONSOLE
			if ((**tH).consolePos > (**tH).selStart)   /* BH: Insertion before marker */
				(**tH).consolePos += textLength;
#endif
			(**tH).teLength = teLength;
			(**tH).nLines += numCRs;

			if (numCRs) {
				LongRectToRect(&((**tH).viewRect),&tempRect);
				tempRect.top = (**tH).destRect.top + (firstLine + 1) * (**tH).lineHeight;
				if (tempRect.top < (**tH).viewRect.top)
					tempRect.top = (**tH).viewRect.top;
					
				GetPort(&oldPort);
				SetPort((**tH).inPort);
				
				updateRgn = NewRgn();
				ScrollRect(&tempRect,0,(**tH).lineHeight * numCRs,updateRgn);
#if TARGET_CPU_PPC
				GetRegionBounds (updateRgn, &r);
				RectToLongRect (&r, &updateRect);
#else
				RectToLongRect (&(**updateRgn).rgnBBox, &updateRect);
#endif
				DisposeRgn(updateRgn);

				TE32KUpdate (&updateRect, tH);

				SetPort(oldPort);
			}
			
			updateLine(firstLine,tH,true,0);
			
			TE32KSetSelect ((**tH).selStart + textLength, (**tH).selStart + textLength, tH);
			
		}
	}
	HUnlock((**tH).hText);
}

void TE32KPaste(TE32KHandle tH)
{
	long len, offset;
	Handle scrapH;
	
	PScrapStuff sInfo;

	if (!tH) 
		return;

#if !TARGET_API_MAC_CARBON
	sInfo = InfoScrap();
	if (sInfo->scrapState < 0 ) {
		ZeroScrap (); /* initialize scrap if necessary */
		return;
	}
#endif

	scrapH = NewHandle (0);   /* allocating on temp heap might cause trouble */
	if (!scrapH || MemError ())
		return;
	len = GetScrap (scrapH,'TEXT',&offset);
	if (len > 0) {
		if ((**tH).selStart < (**tH).selEnd)
			TE32KDelete( tH);
			
#ifdef __UNDOACTION__
		else {
			(**tH).resetUndo = true;
			(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
			if((**tH).undoBuf)
				DisposeHandle((**tH).undoBuf);
			(**tH).undoBuf = 0;
#if MARKS
			(**tH).undoDelta = 0;
#endif
		}
#endif
	
		HLock(scrapH);
						
		TE32KInsert(*scrapH, len, tH);
		
		HUnlock(scrapH);

	}
	DisposeHandle (scrapH);
}

void TE32KSelView(TE32KHandle tH)
{	positionView(tH,0); }

void positionView(TE32KHandle tH, long position)
{
	register long	deltaV,deltaH,screenLines,lineHeight,viewTop,viewBot,selPtV,ascent;
	LongPoint selPt;

	if (tH) {
		if ((**tH).selStart != (**tH).selEnd) {
			if (TE32KAnchor == (**tH).selStart)
				TE32KGetPoint((**tH).selEnd,&selPt,tH);
			else 
				TE32KGetPoint((**tH).selStart,&selPt,tH);
			(**tH).selPoint=selPt;
		}
		selPtV = (**tH).selPoint.v;
		viewTop = (**tH).viewRect.top;
		viewBot = (**tH).viewRect.bottom;
		lineHeight = (**tH).lineHeight;
		ascent = (**tH).fontAscent;
		screenLines = (viewBot - viewTop) / lineHeight;
		
		/*
			Calculate any lack of registation of whole lines with top of window. 
			The result, i.e. deltaV, should be zero if everything is well-behaved. 
		*/
		
		deltaV = viewTop - (**tH).destRect.top;
		deltaV -= (deltaV/lineHeight)*lineHeight;
		
		/*	DeltaV is always calculated and used */
		
		if (selPtV - ascent < viewTop) {
			deltaV += viewTop-(selPtV-ascent);
			if(position)
				deltaV+=(screenLines/3)*lineHeight;
		} else if (selPtV >= viewBot+ascent-lineHeight) {
			deltaV -= (selPtV-ascent+lineHeight)-(viewTop+screenLines*lineHeight);
			if(position)
				deltaV-=(screenLines*2/3)*lineHeight;
		}
		
		/*============= 1/8/94 ===============
			DeltaH is not appropiate if we are word wrapping. Cases where a typed 
			whitespace character (space or tab) exceed the right window boundary
			are trapped by TE32KKey. 
		*/
		
		if((**tH).crOnly) {
			if ((**tH).selPoint.h <= (**tH).viewRect.left) {
				deltaH = (**tH).viewRect.left - (**tH).selPoint.h;
				deltaH = (2 + deltaH/(**tH).lineHeight) * (**tH).lineHeight;
				
				if ((**tH).destRect.left + deltaH > (**tH).viewRect.left)
					deltaH = (**tH).viewRect.left - (**tH).destRect.left;
			} else if ((**tH).selPoint.h > (**tH).viewRect.right) {
				deltaH = (**tH).selPoint.h - (**tH).viewRect.right;
				deltaH = -(2 + deltaH/(**tH).lineHeight) * (**tH).lineHeight;
			} else
				deltaH = 0;
		} else
			deltaH = 0;
		
#if 0
		if ((**tH).destRect.top + deltaV > (**tH).viewRect.top)  /* BH: limit scrolling */
			deltaV = (**tH).viewRect.top - (**tH).destRect.top;
		if ((**tH).destRect.left + deltaH > (**tH).viewRect.left)
			deltaH = (**tH).viewRect.left - (**tH).destRect.left;
#endif
		if (deltaV || deltaH)
			TE32KScroll(deltaH,deltaV,tH);
	}
}

static Boolean DoDeleteKey(TE32KHandle tH)
/*  Returns true if doc did change */
{
	Rect			tempRect;
	RgnHandle		updateRgn;
	short			chWidth;
	long			firstLine;
	register short	*theCharWidths;
	register long	i,*lineStarts,selIndex,*otherLine;
	LongRect		updateRect;
	LongPoint		selPt;
	unsigned char	ch,prevChar;
	GrafPtr			oldPort;

	if ((**tH).selStart < (**tH).selEnd) {
		TE32KDelete(tH);
		return true;
	}
	if ((**tH).selStart > 0) {
		ch = ((unsigned char *) *((**tH).hText))[(**tH).selStart - 1];
		
		if ((**tH).selStart >= 2)
			prevChar = ((unsigned char *) *((**tH).hText))[(**tH).selStart - 2];
		else
			prevChar = '\0';
		
		firstLine = indexToLine((**tH).selStart,tH);
		
#ifdef __UNDOACTION__
		if((**tH).resetUndo) {
			(**tH).resetUndo = false;
			(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
			if((**tH).undoBuf)
				DisposeHandle((**tH).undoBuf);
			(**tH).undoBuf = 0;
#if MARKS
			(**tH).undoDelta = 0;
#endif
		}
		(**tH).undoEnd--;
		if((**tH).undoEnd < (**tH).undoStart) {
			/*	We have deleted past beginning of original selection. Need to
				grow the undo buffer backwards. */
			if((**tH).undoBuf) {
				i=GetHandleSize((**tH).undoBuf);
				SetHandleSize((**tH).undoBuf,i+1);
			} else {
				(**tH).undoBuf=NEWHANDLE(1);
				i=0;
			}
			if (MEMERROR() == noErr) {
				HLock((**tH).undoBuf);
				if(i)
					BlockMove(*(**tH).undoBuf,*(**tH).undoBuf+1,i);
				*(*(**tH).undoBuf)=ch;
				HUnlock((**tH).undoBuf);
			} else {
				doMessage (1);
				(**tH).undoBuf = 0;
			}
		}
#endif

		HLock((**tH).hText);
		BlockMove(*((**tH).hText)+(**tH).selStart,*((**tH).hText)+(**tH).selStart-1,(**tH).teLength-(**tH).selEnd);
		HUnlock((**tH).hText);
		
#if ASCONSOLE
		if ((**tH).consolePos >= (**tH).selStart)
			(**tH).consolePos --;
#endif
		(**tH).teLength--;
		(**tH).selStart--;
		(**tH).selEnd = (**tH).selStart;
		if (ISEOL(ch) && 
			((**tH).crOnly || (**tH).teLength == (**tH).selStart || ISEOL(prevChar))) {

			lineStarts = &((**tH).lineStarts[firstLine]);
			otherLine = &((**tH).lineStarts[firstLine + 1]);
			
			i = (**tH).nLines - firstLine;
			
			while (i--) {
				selIndex = *(otherLine++);
				*(lineStarts++) = --selIndex;
			}
			
			(**tH).nLines--;
			
			if (firstLine > 0)
				firstLine--;
			
			updateRect = (**tH).viewRect;
			updateRect.top = (**tH).destRect.top + firstLine * (**tH).lineHeight;
			updateRect.bottom = updateRect.top + (**tH).lineHeight;
			TE32KUpdate(&updateRect,tH);
			
			LongRectToRect(&updateRect,&tempRect);
			tempRect.top = tempRect.bottom;
			
			tempRect.bottom = Clip2Short((**tH).viewRect.bottom);
			
			GetPort(&oldPort);
			SetPort((**tH).inPort);
		
			updateRgn = NewRgn();
			ScrollRect(&tempRect,0,-(**tH).lineHeight,updateRgn);
#if TARGET_CPU_PPC
			GetRegionBounds (updateRgn, &tempRect);
#else
			tempRect = (**updateRgn).rgnBBox;
#endif
			DisposeRgn(updateRgn);
			
			SetPort(oldPort);
			
			TE32KGetPoint((**tH).selStart,&selPt,tH);
			(**tH).selPoint = selPt;
			
			RectToLongRect(&tempRect,&updateRect);
			
			mClearCaret(tH);
		
			TE32KUpdate(&updateRect,tH);
			
		} else {
		
			lineStarts = &((**tH).lineStarts[(**tH).nLines]);
			i = (**tH).nLines - firstLine;
			
			if (ISEOL(ch))
				i++;
			
			
			while (i--)
				(*(lineStarts--))--;
			
			theCharWidths = (**tH).theCharWidths;
			
			if (ch == TAB)
				chWidth = (**tH).tabWidth;
			else
				chWidth = theCharWidths[ch];
			
			if (ISEOL(ch)) {
				firstLine--;
				
				updateRect.top = (**tH).destRect.top + firstLine * (**tH).lineHeight;
				updateRect.bottom = updateRect.top + (**tH).lineHeight;
				updateRect.left = (**tH).viewRect.left;
				updateRect.right = (**tH).viewRect.right;

			} else {
			
				updateRect.top = (**tH).destRect.top + firstLine * (**tH).lineHeight;
				updateRect.bottom = updateRect.top + (**tH).lineHeight;
				updateRect.left = (**tH).selPoint.h - chWidth;
				updateRect.right = (**tH).viewRect.right;
			}
			
			mClearCaret(tH);
			
			if ((**tH).crOnly)
				TE32KUpdate(&updateRect,tH);
			else 
				updateLine(firstLine,tH,true,&updateRect);

		}
		return true;
	}
	return false;
}

static Boolean DoForwardDelete(TE32KHandle tH)
{
	if ((**tH).selStart < (**tH).selEnd) {
		TE32KDelete(tH);
		return true;
	}
	if((**tH).selStart<(**tH).teLength) {
		(**tH).selStart++;
		(**tH).selEnd=(**tH).selStart;
		return DoDeleteKey(tH);
	}
	return false;
}

static void DoHorizontalArrowKeys(unsigned char ch,TE32KHandle tH,short modifiers)
{
	long 		thisLine,target;
	char		*p;

	if(ch==RIGHTARROW) {
		target=(TE32KAnchor==(**tH).selEnd)?(**tH).selStart:(**tH).selEnd;
		if((**tH).selStart<(**tH).selEnd && !(modifiers&shiftKey))
				target = (**tH).selEnd;  /* BH: cursor should unselect and move to right of insertion */
		else if(target<(**tH).teLength) {
			if(modifiers&cmdKey) {		/* go to end of line, not paragraph */
				thisLine=indexToLine(target,tH);
				if((thisLine+1)<(**tH).nLines) {
					thisLine++;
					target=(**tH).lineStarts[thisLine]-1;
				} else
					target=(**tH).teLength;
			} else if(modifiers&optionKey) {	/* go to end of word or line */
				thisLine=indexToLine(target,tH);
				HLock((**tH).hText);
				p=(*(**tH).hText)+target;
				p++; target++;
				if (target > (**tH).selEnd) {/* BH:if we are extending the selection range */
					while(!isIdChar(*p) && target<(**tH).lineStarts[thisLine+1]) { p++; target++; }
					while(isIdChar(*p) && target<(**tH).lineStarts[thisLine+1]) { p++; target++; }
				} else {
					while(isIdChar(*p) && target<(**tH).lineStarts[thisLine+1]) { p++; target++; }
					while(!isIdChar(*p) && target<(**tH).lineStarts[thisLine+1]) { p++; target++; }
					if (target > (**tH).selEnd) target = (**tH).selEnd;
				}
				HUnlock((**tH).hText);
			} else if((**tH).selStart>=(**tH).selEnd || modifiers&shiftKey)
				target++;
		}
	} else {
		target=(TE32KAnchor==(**tH).selStart)?(**tH).selEnd:(**tH).selStart;
		if((**tH).selStart<(**tH).selEnd && !(modifiers&shiftKey)) 
			target = (**tH).selStart;  /* BH: cursor should unselect and move to left of insertion */
		else if(target) {
			if(modifiers&cmdKey) {
				thisLine=indexToLine(target,tH);
				target=(**tH).lineStarts[thisLine];
			} else if(modifiers&optionKey) {
				thisLine=indexToLine(target,tH);
				if(thisLine>0 && target==(**tH).lineStarts[thisLine])
					thisLine--;
				HLock((**tH).hText);
				p=(*(**tH).hText)+target;
				p--;
				if (target <= (**tH).selStart) {/* BH:if we are extending the selection range */
					while(!isIdChar(*p) && target>(**tH).lineStarts[thisLine]) { p--; target--; }
					while(isIdChar(*p) && target>(**tH).lineStarts[thisLine]) { p--; target--; }
				} else {
					while(isIdChar(*p) && target>(**tH).lineStarts[thisLine]) { p--; target--; }
					while(!isIdChar(*p) && target>(**tH).lineStarts[thisLine]) { p--; target--; }
					if (target < (**tH).selStart) target = (**tH).selStart;
				}
				HUnlock((**tH).hText);
			} else if(((**tH).selStart>=(**tH).selEnd) && target || modifiers&shiftKey)
				target--;
		}
	}
	if(modifiers&shiftKey) {	/* Extend the selection */
		if (ch==LEFTARROW) {
			if(TE32KAnchor==(**tH).selStart) {
				if(target>TE32KAnchor)	{			/* Reduce selection */
					extendHilite((**tH).selEnd,target,tH);
					(**tH).selEnd = target;
				} else {								/* Flip selection to other side of anchor */
					TE32KSetSelect(target,TE32KAnchor,tH);
					TE32KAnchor=(**tH).selEnd;
				}
			} else {
				extendHilite(target,(**tH).selStart,tH);
				TE32KAnchor = (**tH).selEnd;
				(**tH).selStart = target;
			}
		} else if (ch==RIGHTARROW) {
			if(TE32KAnchor==(**tH).selEnd) {
				if(target<TE32KAnchor) {
					extendHilite(target,(**tH).selStart,tH);
					(**tH).selStart = target;
				} else {
					TE32KSetSelect(TE32KAnchor,target,tH);
					TE32KAnchor = (**tH).selStart;
				}
			} else {
				extendHilite((**tH).selEnd,target,tH);				/*  Extend down */
				TE32KAnchor = (**tH).selStart;
				(**tH).selEnd = target;
			}
		}
	} else {
		TE32KSetSelect(target,target,tH);
		TE32KAnchor = -1;
	}
	TE32KHPos = -1;
}

static void DoVerticalArrowKeys(unsigned char ch,TE32KHandle tH,short modifiers)
{
	LongPoint		selPt,tempPt1,tempPt2;
	long			firstLine,selIndex;

	if(modifiers&cmdKey && modifiers&optionKey) {
		TE32KHPos = -1;
		if(ch==UPARROW) {
			if(modifiers&shiftKey) {
				TE32KSetSelect(0,(**tH).selEnd,tH);
				TE32KAnchor = (**tH).selEnd;
			} else 
				TE32KSetSelect(0,0,tH);
			return;
		}
		if(ch==DOWNARROW) {
			if(modifiers&shiftKey) {
				TE32KSetSelect((**tH).selStart,(**tH).teLength,tH);
				TE32KAnchor = (**tH).selStart;
			} else 
				TE32KSetSelect((**tH).teLength,(**tH).teLength,tH);				
			return;
		}
	}
	
	mClearCaret(tH);
	
	if(modifiers&shiftKey) {	/*  Extend the selection */
		if(ch==UPARROW) {
			firstLine = indexToLine((**tH).selStart,tH);
			if(firstLine > 0) {
				if(TE32KAnchor==(**tH).selStart) {
					TE32KGetPoint((**tH).selEnd,&selPt,tH);
					selPt.v -= (**tH).lineHeight;
					
					if(TE32KHPos==-1) 
						TE32KHPos=selPt.h;
					else
						selPt.h=TE32KHPos;
						
					selIndex = TE32KGetOffset(&selPt,tH);
					if(selIndex>TE32KAnchor)	{			/* Reduce selection */
						extendHilite((**tH).selEnd,selIndex,tH);
						(**tH).selEnd = selIndex;
					} else {								/* Flip selection to other side of anchor */
						TE32KSetSelect(selIndex,TE32KAnchor,tH);
						TE32KAnchor=(**tH).selEnd;
					}
				} else {
					TE32KGetPoint((**tH).selStart,&selPt,tH);
					selPt.v -= (**tH).lineHeight;
					
					if(TE32KHPos==-1) 
						TE32KHPos=selPt.h;
					else
						selPt.h=TE32KHPos;
						
					selIndex = TE32KGetOffset(&selPt,tH);
					extendHilite(selIndex,(**tH).selStart,tH);
					TE32KAnchor = (**tH).selEnd;
					(**tH).selStart = selIndex;
				}
			}
		} else if (ch==DOWNARROW) {
			firstLine = indexToLine((**tH).selEnd,tH);
			if (firstLine < (**tH).nLines - 1) {
				if(TE32KAnchor==(**tH).selEnd) {
					TE32KGetPoint((**tH).selStart,&selPt,tH);
					selPt.v += (**tH).lineHeight;
					
					if(TE32KHPos==-1) 
						TE32KHPos=selPt.h;
					else
						selPt.h=TE32KHPos;
						
					selIndex = TE32KGetOffset(&selPt,tH);
					if(selIndex<TE32KAnchor) {
						extendHilite(selIndex,(**tH).selStart,tH);
						(**tH).selStart = selIndex;
					} else {
						TE32KSetSelect(TE32KAnchor,selIndex,tH);
						TE32KAnchor = (**tH).selStart;
					}
				} else {
					TE32KGetPoint((**tH).selEnd,&selPt,tH);
					selPt.v += (**tH).lineHeight;
					
					if(TE32KHPos==-1) 
						TE32KHPos=selPt.h;
					else
						selPt.h=TE32KHPos;
						
					selIndex = TE32KGetOffset(&selPt,tH);
					extendHilite((**tH).selEnd,selIndex,tH);				/*  Extend down */
					TE32KAnchor = (**tH).selStart;
					(**tH).selEnd = selIndex;
				}
			}
		}
	} else {
	
		TE32KAnchor = -1;
		
		if ((**tH).selStart < (**tH).selEnd)
			invertSelectRgn(tH);							/*  remove selection */

		if ((**tH).selStart < (**tH).selEnd) {				
			if (ch == DOWNARROW)
				TE32KGetPoint((**tH).selEnd,&selPt,tH);
			else
				TE32KGetPoint((**tH).selStart,&selPt,tH);
									
			(**tH).selPoint = selPt;
		}
		
		selPt = (**tH).selPoint;
			
		if(TE32KHPos==-1) 
			TE32KHPos=selPt.h;
		else
			selPt.h=TE32KHPos;
			
		if (ch==UPARROW) {

			firstLine = indexToLine((**tH).selStart,tH);
			
			if (firstLine > 0) {
				selPt.v -= (**tH).lineHeight;
				(**tH).selStart = TE32KGetOffset(&selPt,tH);
				(**tH).selEnd = (**tH).selStart;
				firstLine = indexToLine((**tH).selStart,tH);
				
				if (!(**tH).crOnly && (**tH).selStart == (**tH).lineStarts[firstLine]) {
					(**tH).clikStuff = false;
					TE32KGetPoint((**tH).selStart,&tempPt1,tH);
					
					(**tH).clikStuff = true;
					TE32KGetPoint((**tH).selStart,&tempPt2,tH);
					
					if ((selPt.h - tempPt1.h)*(selPt.h - tempPt1.h) + (selPt.v - tempPt1.v)*(selPt.v - tempPt1.v) <
						(selPt.h - tempPt2.h)*(selPt.h - tempPt2.h) + (selPt.v - tempPt2.v)*(selPt.v - tempPt2.v))
							(**tH).selPoint = tempPt1;
					else
							(**tH).selPoint = tempPt2;
					
					return;
				} else {
					(**tH).clikStuff = false;
					TE32KGetPoint((**tH).selStart,&selPt,tH);
					(**tH).selPoint = selPt;
				}
			}
		} else {

			firstLine = indexToLine((**tH).selStart,tH);
			
			if (firstLine < (**tH).nLines) {
				selPt.v += (**tH).lineHeight;
				(**tH).selEnd = TE32KGetOffset(&selPt,tH);
				(**tH).selStart = (**tH).selEnd;
				firstLine = indexToLine((**tH).selEnd,tH);
				
				if (!(**tH).crOnly && (**tH).selStart == (**tH).lineStarts[firstLine]) {
					(**tH).clikStuff = false;
					TE32KGetPoint((**tH).selStart,&tempPt1,tH);
					
					(**tH).clikStuff = true;
					TE32KGetPoint((**tH).selStart,&tempPt2,tH);
					
					if ((selPt.h - tempPt1.h)*(selPt.h - tempPt1.h) + (selPt.v - tempPt1.v)*(selPt.v - tempPt1.v) <
						(selPt.h - tempPt2.h)*(selPt.h - tempPt2.h) + (selPt.v - tempPt2.v)*(selPt.v - tempPt2.v))
							(**tH).selPoint = tempPt1;
					else
							(**tH).selPoint = tempPt2;
					
					return;
				} else {
					(**tH).clikStuff = false;
					TE32KGetPoint((**tH).selEnd,&selPt,tH);
					(**tH).selPoint = selPt;
				}
			}
		}
		
		(**tH).selEnd = (**tH).selStart;
		xorCaret(tH);
	}
}

static void DoNormalChar(unsigned char ch,TE32KHandle tH)
{
	LongRect		tempRect;  /* BH: changed Rect to LongRect; see below */
	short			destLeftSide;
	long			teLength,thisLine;
	register long	i,*lineStarts,delta;
	LongPoint		selPt;
	unsigned char	prevChar;
	
	teLength = (**tH).teLength + 1;
	
	if (GetHandleSize((**tH).hText) < teLength) {
		SetHandleSize((**tH).hText,teLength + EXTRATEXTBUFF);
		
		if (MEMERROR() || GetHandleSize((**tH).hText) < teLength) {
			doMessage(1);
			return;
		}
	}
	
	mClearCaret(tH);
	
	selPt = (**tH).selPoint;
		
	thisLine = indexToLine((**tH).selStart,tH);
	if ((**tH).selStart > 0)
		prevChar = ((unsigned char *) *(**tH).hText)[(**tH).lineStarts[thisLine] - 1];
	else
		prevChar = NEWLINE;  /*BH: changed '\n' to NEWLINE */
	
#if 0
/* BH: the following doen't work with tabs, so let TE32KUpdate do the screen update */

	/* 		We will draw the character unless we are wordwrapping and the character is a 
		space at the end of a line. 
	*/
	
	if ((**tH).crOnly || ISEOL(prevChar) ||
			!(ch == ' ' && ((**tH).selStart == (**tH).lineStarts[thisLine]))) {
		
		if((**tH).selStart == (**tH).lineStarts[thisLine]) {
			TE32KGetPoint((**tH).selStart,&selPt,tH);
		}
			

		tempRect.left = Clip2Short(selPt.h);
		tempRect.right = Clip2Short((**tH).viewRect.right);
		
		selPt.v -= (**tH).fontAscent;
		tempRect.top = Clip2Short(selPt.v);
		
		tempRect.bottom = tempRect.top + (**tH).lineHeight;
		
		GetPort(&oldPort);
		SetPort((**tH).inPort);
		
		oldFont = ((**tH).inPort)->txFont;
		oldFace = ((**tH).inPort)->txFace;
		oldSize = ((**tH).inPort)->txSize;
		oldMode = ((**tH).inPort)->txMode;
		
		TextFont((**tH).txFont);
		TextFace((**tH).txFace);
		TextSize((**tH).txSize);
		TextMode((**tH).txMode);
		
		theCharWidths = (**tH).theCharWidths;
		
		if (ch == TAB) {
			destLeftSide = (**tH).destRect.left + 1;
			delta = (**tH).tabWidth;
			chWidth = (destLeftSide + ((tempRect.left  - destLeftSide + delta)/delta)*delta) - tempRect.left;
		} else 
			chWidth = theCharWidths[ch];
		
		if (tempRect.left < tempRect.right) {	
			updateRgn = NewRgn();
			ScrollRect(&tempRect,chWidth,0,updateRgn);
			
			if (tempRect.left + chWidth > tempRect.right)
				ClipRect(&tempRect);
			
			MoveTo(tempRect.left,tempRect.top + (**tH).fontAscent);
			if((**tH).showInvisibles) {
				if (ch <= 0x20 || isspace (ch))
					DrawSpecialChar ((**tH).theCharWidths, ch);  /* BH: changed to be coherent with TE32KUpdate */		
			} else if (ch != TAB)
				DrawChar(ch);
			
			if (tempRect.left + chWidth > tempRect.right) {
				tempRect.left = -kMaxShort;
				tempRect.top = -kMaxShort;
				tempRect.right = kMaxShort;
				tempRect.bottom = kMaxShort;
				ClipRect(&tempRect);
			}
			
			DisposeRgn(updateRgn);
		}
		
		TextFont(oldFont);
		TextFace(oldFace);
		TextSize(oldSize);
		TextMode(oldMode);
		
		SetPort(oldPort);

#endif
	
	HLock((**tH).hText);
	BlockMove(*((**tH).hText) + (**tH).selStart,*((**tH).hText) + (**tH).selStart + 1,(**tH).teLength - (**tH).selStart);	
	((unsigned char *) *((**tH).hText))[(**tH).selStart] = ch;
	HUnlock((**tH).hText);
	
	lineStarts = &((**tH).lineStarts[(**tH).nLines]);
	i = (**tH).nLines - thisLine;
	
	if (!(**tH).crOnly && ISNEOL(prevChar) && ch == ' ' && (**tH).selStart == (**tH).lineStarts[thisLine])
		i++;
	
	while (i--)
		(*(lineStarts--))++;
	
#ifdef __UNDOACTION__

	if((**tH).resetUndo) {
		(**tH).resetUndo = false;
		(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
		if((**tH).undoBuf)
			DisposeHandle((**tH).undoBuf);
		(**tH).undoBuf = 0;
#if MARKS
		(**tH).undoDelta = 0;
#endif
	}
	if((**tH).undoEnd<(**tH).undoStart)		/* added a character after a series of deletes */
		(**tH).undoStart=(**tH).undoEnd;
		
	(**tH).undoEnd++;
		
#endif

#if ASCONSOLE
		if ((**tH).consolePos > (**tH).selStart)  /*BH: insertion before marker */
				(**tH).consolePos++; /*BH: use >= for insertion after marker */
#endif
	(**tH).teLength++;
	(**tH).selStart++;
	(**tH).selEnd = (**tH).selStart;
	
/*the following now does the update */

	if((**tH).selStart == (**tH).lineStarts[thisLine]) 
		TE32KGetPoint((**tH).selStart,&selPt,tH);
	tempRect.left = selPt.h;
	tempRect.right = (**tH).viewRect.right;
	
	selPt.v -= (**tH).fontAscent;
	tempRect.top = selPt.v;
	
	tempRect.bottom = tempRect.top + (**tH).lineHeight;

	if (ch == TAB) {
		destLeftSide = (**tH).destRect.left + 1;
		delta = (**tH).tabWidth;
		(**tH).selPoint.h += (destLeftSide + ((tempRect.left  - destLeftSide + delta)/delta)*delta) - tempRect.left;
	} else 
		(**tH).selPoint.h += (**tH).theCharWidths[ch];

	TE32KUpdate (&tempRect, tH);

/*	if (!(**tH).crOnly && !isspace(ch)) */
	if (!(**tH).crOnly)
		updateLine(thisLine,tH,false,0);
	
	xorCaret(tH);
}

static void DoReturnChar(TE32KHandle tH)
{
	Rect			tempRect;
	RgnHandle		updateRgn;
	long			teLength,firstLine,lastLine,deltaLines,numAffected,tempFirstLine;
	register long	cnt,*lineStarts,selIndex,*otherLine;
	long			indentCnt=0,leadingCnt=0,indent;
	LongPoint		selPt;
	LongRect		updateRect;
	unsigned char	doWrap,*p;
	GrafPtr			oldPort;
	Handle			undoH;

	teLength = GetHandleSize((Handle) tH);
	lastLine  = (teLength - (long) sizeof(TE32KRec))/(long) sizeof(long) - 2;
	
	if ((**tH).nLines + 1 >= lastLine) {
		teLength = (long) sizeof(TE32KRec) + (long) sizeof(long)*((**tH).nLines + 1 + EXTRALINESTARTS);
		
		SetHandleSize((Handle) tH,teLength);
		
		if (MEMERROR()  || GetHandleSize((Handle)tH) < teLength) {
			doMessage(1);
			return;
		}
	}
		
	firstLine = indexToLine((**tH).selStart,tH);
	
	mClearCaret(tH);

	if ((**tH).autoIndent) {
		HLock((**tH).hText);
		
		if((**tH).crOnly) 
			indent = (**tH).lineStarts[firstLine];
		else {
			tempFirstLine = indexToParagraph((**tH).selStart,tH);
			indent = (**tH).lineStarts[tempFirstLine];
		}
			
		cnt = (**tH).teLength - indent; /* BH: insert cnt to limit search */
		p=((unsigned char *) *(**tH).hText)+indent;
		while(cnt-- && (*p==' ' || *p==TAB)) { p++; indentCnt++; }
		
		cnt = (**tH).teLength - (**tH).selStart; /* BH: insert cnt to limit search */
		p=((unsigned char *) *(**tH).hText)+(**tH).selStart;
		while(cnt-- && (*p==' ' || *p==TAB)) { p++; leadingCnt++; }  
		
#ifdef __UNDOACTION__
		if(leadingCnt) {
			if((**tH).undoBuf)
				DisposeHandle((**tH).undoBuf);
			undoH=NEWHANDLE(leadingCnt);
			if (MEMERROR() || undoH==NULL) {
				doMessage(1);
				undoH=0;
			} else {
				HLock(undoH);
				BlockMove(*((**tH).hText) + (**tH).selStart,*undoH,leadingCnt);
				HUnlock(undoH);
			}
			(**tH).undoBuf=undoH;
			(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
			(**tH).resetUndo = false;
#if MARKS
			(**tH).undoDelta = 0;
#endif
		}
#endif

		teLength = (**tH).teLength + indentCnt - leadingCnt + 1;
		
		if (GetHandleSize((**tH).hText) < teLength) {
		
			HUnlock((**tH).hText);
			SetHandleSize((**tH).hText,teLength + EXTRATEXTBUFF);
			
			if (MEMERROR() || GetHandleSize((**tH).hText) < teLength) {
				doMessage(1);
				return;
			}
			HLock((**tH).hText);
		}
		BlockMove(*((**tH).hText) + (**tH).selStart + leadingCnt,
				*((**tH).hText) + (**tH).selStart + indentCnt + 1,
				(**tH).teLength - (**tH).selStart - leadingCnt);
		p=((unsigned char *) *(**tH).hText)+indent; 
		BlockMove(p,*((**tH).hText) + (**tH).selStart + 1,indentCnt);
		((unsigned char *) *((**tH).hText))[(**tH).selStart] = NEWLINE;  /*BH: add NEWLINE character instead of RETURN */
		
		HUnlock((**tH).hText);
		
			HUnlock((**tH).hText);
	} else {
		teLength = (**tH).teLength + 1;
		
		if (GetHandleSize((**tH).hText) < teLength) {
			SetHandleSize((**tH).hText,teLength + EXTRATEXTBUFF);
			
			if (MEMERROR() || GetHandleSize((**tH).hText) < teLength) {
				doMessage(1);
				HUnlock((**tH).hText);
				return;
			}
		}
		HLock((**tH).hText);
		BlockMove(*((**tH).hText) + (**tH).selStart,*((**tH).hText) + (**tH).selStart + 1,(**tH).teLength - (**tH).selStart);	
		((unsigned char *) *((**tH).hText))[(**tH).selStart] = NEWLINE;  /*BH: changed RETURN to NEWLINE */
		HUnlock((**tH).hText);
	}
	
	lineStarts = &((**tH).lineStarts[(**tH).nLines]);
	otherLine = &((**tH).lineStarts[(**tH).nLines + 1]);
	cnt = (**tH).nLines - firstLine;
		
	if(indentCnt-leadingCnt) {
		while (cnt--) {
			selIndex = *(lineStarts--);
			*(otherLine--) = (selIndex+=(indentCnt-leadingCnt+1));
		}
	} else {
		while (cnt--) {
			selIndex = *(lineStarts--);
			*(otherLine--) = ++selIndex;
		}
	}
	
	(**tH).lineStarts[firstLine + 1] = (**tH).selStart + 1;
	
#ifdef __UNDOACTION__

	if((**tH).resetUndo) {
		(**tH).resetUndo = false;
		(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
		if((**tH).undoBuf)
			DisposeHandle((**tH).undoBuf);
		(**tH).undoBuf = 0;
#if MARKS
		(**tH).undoDelta = 0;
#endif
	}
	if((**tH).undoEnd<(**tH).undoStart)		/* added a character after a series of deletes */
		(**tH).undoStart=(**tH).undoEnd;
		
	(**tH).undoEnd+=(indentCnt+1);
	
#endif

	(**tH).nLines++;
	(**tH).teLength+=(indentCnt-leadingCnt+1);
#if ASCONSOLE
		if ((**tH).consolePos > (**tH).selStart) /*BH:insertion before marker */
			(**tH).consolePos +=(indentCnt+1); /*BH: use >= for insertion after marker. */
#endif
	(**tH).selStart+=(indentCnt+1);
	(**tH).selEnd = (**tH).selStart;
	
	LongRectToRect(&((**tH).viewRect),&tempRect);
	
	selPt = (**tH).selPoint;
	selPt.v -= (**tH).fontAscent;
	selPt.v += (**tH).lineHeight;
	
	tempRect.top = Clip2Short(selPt.v);
	
	GetPort(&oldPort);
	SetPort((**tH).inPort);
			
	updateRgn = NewRgn();
	ScrollRect(&tempRect,0,(**tH).lineHeight,updateRgn);
	DisposeRgn(updateRgn);
	
	SetPort(oldPort);
	
	if (!(**tH).crOnly) {
		doWrap = false;
		tempFirstLine = firstLine;
		
		if (tempFirstLine > 0 && LineEndIndex(tempFirstLine - 1,tH) != (**tH).lineStarts[tempFirstLine]) {
			doWrap = true;
			tempFirstLine--;
		} else if (LineEndIndex(tempFirstLine,tH) != (**tH).lineStarts[tempFirstLine + 1])
			doWrap = true;
		
		
		if (doWrap) {
			CalParagraph(tempFirstLine,tH,&deltaLines,&numAffected);
			
			if (deltaLines == 0) {
				updateRect = (**tH).viewRect;
				updateRect.top = (**tH).destRect.top + tempFirstLine * (**tH).lineHeight;
				updateRect.bottom = updateRect.top + (**tH).lineHeight * numAffected;
			} else if (deltaLines > 0) {
			
				firstLine += deltaLines;
				
				LongRectToRect(&((**tH).viewRect),&tempRect);
				tempRect.top = (**tH).destRect.top + (tempFirstLine + numAffected - deltaLines) * (**tH).lineHeight;
				
				GetPort(&oldPort);
				SetPort((**tH).inPort);
				
				updateRgn = NewRgn();
				ScrollRect(&tempRect,0,(**tH).lineHeight * deltaLines,updateRgn);
				DisposeRgn(updateRgn);
				
				SetPort(oldPort);
				
				updateRect = (**tH).viewRect;
				updateRect.top = (**tH).destRect.top + tempFirstLine * (**tH).lineHeight;
				updateRect.bottom = updateRect.top + (**tH).lineHeight * numAffected;
			} else {
				firstLine += deltaLines;
				
				LongRectToRect(&((**tH).viewRect),&tempRect);
				tempRect.top = (**tH).destRect.top + (tempFirstLine - 1 + numAffected) * (**tH).lineHeight;
				
				GetPort(&oldPort);
				SetPort((**tH).inPort);
	
				updateRgn = NewRgn();
				ScrollRect(&tempRect,0,(**tH).lineHeight * deltaLines,updateRgn);
				DisposeRgn(updateRgn);
				
				SetPort(oldPort);
				
				updateRect = (**tH).viewRect;
				updateRect.top = (**tH).destRect.top + tempFirstLine * (**tH).lineHeight;
				updateRect.bottom = updateRect.top + (**tH).lineHeight * numAffected;
			}
			
			TE32KUpdate(&updateRect,tH);
		}
		
		firstLine++;
		
		CalParagraph(firstLine,tH,&deltaLines,&numAffected);
		
		if (deltaLines > 0) {
			LongRectToRect(&((**tH).viewRect),&tempRect);
			tempRect.top = (**tH).destRect.top + (firstLine + numAffected - deltaLines) * (**tH).lineHeight;
			
			GetPort(&oldPort);
			SetPort((**tH).inPort);
	
			updateRgn = NewRgn();
			ScrollRect(&tempRect,0,(**tH).lineHeight * deltaLines,updateRgn);
			DisposeRgn(updateRgn);
			
			SetPort(oldPort);
		} else if (deltaLines < 0) {
			LongRectToRect(&((**tH).viewRect),&tempRect);
			tempRect.top = (**tH).destRect.top + (firstLine - 1 + numAffected) * (**tH).lineHeight;
			
			GetPort(&oldPort);
			SetPort((**tH).inPort);
	
			updateRgn = NewRgn();
			ScrollRect(&tempRect,0,(**tH).lineHeight * deltaLines,updateRgn);
			DisposeRgn(updateRgn);
			
			SetPort(oldPort);
		}
		
		updateRect = (**tH).viewRect;
		updateRect.top = (**tH).destRect.top + (firstLine - 1) * (**tH).lineHeight;
		updateRect.bottom = updateRect.top + (**tH).lineHeight * (numAffected + 1);
		
		mClearCaret(tH);
		
		TE32KUpdate(&updateRect,tH);
		
		TE32KGetPoint((**tH).selStart,&selPt,tH);
		(**tH).selPoint = selPt;
	} else {
		if ((**tH).nLines - firstLine >= 2 && 
			(**tH).lineStarts[firstLine+1]+1 < (**tH).lineStarts[firstLine + 2]) {
			updateRect = (**tH).viewRect;
			TE32KGetPoint((**tH).selStart,&selPt,tH);
			(**tH).selPoint = selPt;
			updateRect.top = (**tH).destRect.top + firstLine * (**tH).lineHeight;
			updateRect.bottom = updateRect.top + (**tH).lineHeight + (**tH).lineHeight;
			TE32KUpdate(&updateRect,tH);
		} else if((**tH).showInvisibles) {
			GetPort(&oldPort);
			SetPort((**tH).inPort);
			selPt = (**tH).selPoint;
			MoveTo(selPt.h,selPt.v);
			DrawChar('¬');
			
			TE32KGetPoint((**tH).selStart-indentCnt,&selPt,tH);
			if((**tH).selStart<(**tH).teLength) {
				MoveTo(selPt.h,selPt.v);
				DrawChar('¬');
			}
			TE32KGetPoint((**tH).selStart,&selPt,tH);
			(**tH).selPoint = selPt;
			SetPort(oldPort);
			xorCaret(tH);
		} else {
			TE32KGetPoint((**tH).selStart,&selPt,tH);
			(**tH).selPoint = selPt;
			xorCaret(tH);
		}
	}
}


Boolean TE32KKey(unsigned char ch,TE32KHandle tH,short modifiers)
{
	Boolean ret=true;
	
	if (tH && (**tH).active) {
		ObscureCursor();
		
		if (ch == DELETE)
			if (modifiers & shiftKey)   /* BH: use shift-delete as forward delete */
				DoForwardDelete (tH);
			else 
				DoDeleteKey(tH);
		else if(ch == 0x7F )  
			DoForwardDelete(tH);
		else if (ch==LEFTARROW || ch==RIGHTARROW) {
			DoHorizontalArrowKeys(ch,tH,modifiers);
			ret=false;
		} else if (ch==UPARROW || ch==DOWNARROW) {
			DoVerticalArrowKeys(ch,tH,modifiers);
			ret=false;
		} else {
			if ((**tH).selStart < (**tH).selEnd) 	/* overtype selection */
				TE32KDelete(tH);

			if (ch==RETURN)
				DoReturnChar(tH);
			else if (ch == ENTER) {
				ch = RETURN;
 				DoReturnChar(tH);
			} else
				if (ch == TAB || ch >= ' ') /* BH: don't insert invisibles */
					DoNormalChar(ch,tH);
				else {
					SysBeep (4);
					ret = false;
				}
		}
		
		if ((**tH).selStart == (**tH).selEnd && !(**tH).caretState)
			xorCaret(tH);
			
		return ret;
	}
	return false;
}

static long paraLines(long firstLine, TE32KHandle tH)
{
	long					lastLine,nLines;
	register unsigned char	*charBase;
	register long			*lineStarts;

	if ((**tH).crOnly)
		return(1);
	
	lastLine = firstLine + 1;
	nLines = (**tH).nLines;
	charBase = (unsigned char	*) *((**tH).hText);
	lineStarts = &((**tH).lineStarts[lastLine]);
	
	while (lastLine < nLines && ISNEOL(charBase[*lineStarts - 1])) {
		lastLine++;
		lineStarts++;
	}
	
	return(lastLine - firstLine);
}

/*-----------------------------------------------------------------------
	LineEndIndex returns the index of the last character in a line. This
	is the critical word wrap routine. 
------------------------------------------------------------------------*/

static long	LineEndIndex(long thisLine,TE32KHandle tH)
{
	register unsigned char	*charPtr;
	register long			charCount,tabWidth;
	register short			*theCharWidths,maxLineWidth,lineWidth;
	register unsigned char	ch;
	Boolean					atLineEnd,wrapToLength;
	unsigned char			*charBase;
	Point					cursorPt;
	short					rightSide,destLeftSide;
	short					lineStatus;
	unsigned char			*oldCharPtr;
	long					maxRewind;
	
	if ((**tH).crOnly)
		return((**tH).lineStarts[thisLine + 1]);
	
	wrapToLength = (**tH).wrapToLength;
	maxLineWidth = (wrapToLength)? (**tH).maxLineWidth : kMaxShort ;

	/* we don't have to lock (**th).hText because we don't call any functions */
	
	charBase = (unsigned char *) *((**tH).hText);
	charPtr = charBase + (**tH).lineStarts[thisLine];
	charCount = (**tH).teLength - (**tH).lineStarts[thisLine];
	

	if (charCount > (**tH).teLength)
		charCount = (**tH).teLength;
	
	lineStatus = 0;
	lineWidth = 0;
	
	if (charCount) {
		rightSide = (short) ((**tH).destRect.right);
		destLeftSide = (short) ((**tH).destRect.left + 1);
		cursorPt.h = destLeftSide;
		tabWidth = (long) (**tH).tabWidth;
		
		theCharWidths = (**tH).theCharWidths;
		
		ch = ' ';
		
		while (charCount-- && ISNEOL(ch)) {
			ch = *charPtr++;
			lineWidth++;
			
			if(wrapToLength)
				atLineEnd = (lineWidth > maxLineWidth);
			else {
				if (ch == TAB)
					cursorPt.h = destLeftSide + ((cursorPt.h - destLeftSide + tabWidth)/tabWidth)*tabWidth;
				else
					cursorPt.h += theCharWidths[ch];
					
				atLineEnd = (cursorPt.h >= rightSide && ch != ' '); 
			}
			
			if (atLineEnd) {
				maxRewind = charPtr - charBase - (**tH).lineStarts[thisLine];
				oldCharPtr = charPtr;
				
				charPtr--;
				maxRewind--;
				
				while (*charPtr != ' ' && maxRewind > 0) {
					charPtr--;
					maxRewind--;
				}
				
				if (maxRewind <= 0)
					charPtr = oldCharPtr;
				
				else
					charPtr++;
				
				charCount = 0;
			}
		}
	}
	
	return(charPtr - charBase);
}

#define	NUMTEMPLINES	64

static void CalParagraph(long thisLine,TE32KHandle tH,long *theDeltaLines,long *theNumAffected)

{
	register unsigned char	*charPtr;
	register short			*theCharWidths;
	register long			charCount,*lineStarts,*otherLine,i;
	register long			lineWidth,maxLineWidth,tabWidth;
	register unsigned char	ch;
	register long			nLines;
	Boolean					atLineEnd,wrapToLength;
	long					maxLineStarts,sizeTE32KHandle,oldCharCount;
	unsigned char			*charBase;
	Point					cursorPt;
	short					rightSide,destLeftSide,maxRewind;
	unsigned char			*oldCharPtr;
	long					tempLineStarts[NUMTEMPLINES],oldNumLines,deltaLines;
	
	if ((**tH).crOnly) {
		*theDeltaLines = 0;
		*theNumAffected = 0;
		return;
	}
	
	deltaLines = 0;
	
	oldNumLines = paraLines(thisLine,tH);
	
	wrapToLength = (**tH).wrapToLength;
	
	for (i=0;i<oldNumLines && i <NUMTEMPLINES;i++)
		tempLineStarts[i] = (**tH).lineStarts[thisLine + i];
		
	sizeTE32KHandle  = GetHandleSize((Handle) tH);
	maxLineStarts = (sizeTE32KHandle - (long) sizeof(TE32KRec))/(long) sizeof(long) - 2;
	
	nLines = 0;
	tempLineStarts[nLines] = (**tH).lineStarts[thisLine];
	
	maxLineWidth = (wrapToLength)? (**tH).maxLineWidth : kMaxShort ;
	lineWidth = 0;
	
	charBase = (unsigned char *) *((**tH).hText);
	charPtr = charBase + (**tH).lineStarts[thisLine];
	
	charCount = (**tH).teLength - (**tH).lineStarts[thisLine];
	ch = *charPtr;
	
	if (charCount > 0) {
		rightSide = (short) ((**tH).destRect.right);
		destLeftSide = (short) ((**tH).destRect.left + 1);
		cursorPt.h = destLeftSide;
		tabWidth = (long) (**tH).tabWidth;
		
		theCharWidths = (**tH).theCharWidths;
		
		ch = ' ';
		
		while (ISNEOL(ch) && charCount--) {
			ch = *charPtr++;
			lineWidth++;
			
			if (ISNEOL(ch)) {
			
				if(wrapToLength)
					atLineEnd = (lineWidth > maxLineWidth);
				else {
					if (ch == TAB)
						cursorPt.h = destLeftSide + ((cursorPt.h - destLeftSide + tabWidth)/tabWidth)*tabWidth;
					else
						cursorPt.h += theCharWidths[ch];
						
					atLineEnd = (cursorPt.h >= rightSide && ch != ' '); 
				}
				
				if (atLineEnd) {
					maxRewind = charPtr - charBase - tempLineStarts[nLines];
					oldCharPtr = charPtr;
					oldCharCount = charCount;
					
					charPtr--;
					charCount++;
					maxRewind--;
					
					while (*charPtr != ' ' && maxRewind > 0) {
						charPtr--;
						charCount++;
						maxRewind--;
					}
					
					if (maxRewind <= 0) {
						charPtr = oldCharPtr;
						charCount = oldCharCount;
					} else {
						charPtr++;
						charCount--;
					}
					
					nLines++;
					
					if (nLines < NUMTEMPLINES) {
						if (tempLineStarts[nLines] == charPtr - charBase) {
							oldNumLines = nLines;
							goto STOPWRAPPING;
						} else
							tempLineStarts[nLines] = charPtr - charBase;
					} else
						goto STOPWRAPPING;
					
					cursorPt.h = destLeftSide;
					lineWidth = 0;
				}
			}
		}
		
		nLines++;
		
		if (nLines < NUMTEMPLINES)
			tempLineStarts[nLines] = charPtr - charBase;

STOPWRAPPING:

		deltaLines = nLines - oldNumLines;

		if (nLines >= NUMTEMPLINES) {
			oldNumLines  = (**tH).nLines;
			TE32KCalText(tH);
			deltaLines = (**tH).nLines - oldNumLines;
		} else {
			if (deltaLines == 0) {
				for (i = 1;i <= nLines;i++)
					(**tH).lineStarts[thisLine + i] = tempLineStarts[i];
			}
			
			else if (deltaLines < 0) {
				lineStarts = &((**tH).lineStarts[thisLine + 1]);
				
				for (i = 1;i <= nLines;i++)
					*(lineStarts++) = tempLineStarts[i];
				
				otherLine = &((**tH).lineStarts[thisLine + oldNumLines + 1]);
				i = (**tH).nLines - thisLine - oldNumLines + 1;
				
				while (i--)
					*(lineStarts++) = *(otherLine++);
				
				(**tH).nLines += deltaLines;
			} else {
				if ((**tH).nLines + deltaLines >= maxLineStarts) {
					sizeTE32KHandle = (long) sizeof(TE32KRec) + (long) sizeof(long)*((**tH).nLines + deltaLines + EXTRALINESTARTS);
					maxLineStarts = (sizeTE32KHandle - (long) sizeof(TE32KRec))/(long) sizeof(long) - 2;
					
					SetHandleSize((Handle) tH,sizeTE32KHandle);
					
					if (MEMERROR()) {
						doMessage(1);
						nLines = (**tH).nLines;
						deltaLines = (**tH).nLines;
						goto EXITPOINT;
					}
				}
				
				lineStarts = &((**tH).lineStarts[(**tH).nLines]);
				otherLine = &((**tH).lineStarts[(**tH).nLines + deltaLines]);
				i = (**tH).nLines - thisLine - oldNumLines;
				
				while (i--)
					*(otherLine--) = *(lineStarts--);
					
				for (i = nLines;i >= 0;i--)
					*(otherLine--) = tempLineStarts[i];
				
				(**tH).nLines += deltaLines;
			}
		}
	}
	
EXITPOINT:
	*theNumAffected = nLines;
	*theDeltaLines = deltaLines;
}


static void updateLine(register long thisLine, TE32KHandle tH, short doFirst, LongRect *updateClipRect)
{
	Rect			tempRect;
	RgnHandle		updateRgn;
	LongRect		updateRect;
	LongPoint		selPt;
	unsigned char	doWrap;
	long			deltaLines,numAffected;
	GrafPtr			oldPort;


	updateRect = (**tH).viewRect;
	updateRect.top = (**tH).destRect.top + thisLine * (**tH).lineHeight;
	updateRect.bottom = updateRect.top + (**tH).lineHeight;
	
	if (updateClipRect) {
		if (updateRect.top < updateClipRect->top)
			updateRect.top = updateClipRect->top;
		if (updateRect.bottom > updateClipRect->bottom)
			updateRect.bottom = updateClipRect->bottom;
		if (updateRect.left < updateClipRect->left)
			updateRect.left = updateClipRect->left;
		if (updateRect.right > updateClipRect->right)
			updateRect.right = updateClipRect->right;
	}
	
	doWrap = false;
	
	if (thisLine > 0 && LineEndIndex(thisLine - 1,tH) != (**tH).lineStarts[thisLine]) {
		doWrap = true;
		thisLine--;
	} else if (LineEndIndex(thisLine,tH) != (**tH).lineStarts[thisLine + 1])
		doWrap = true;
	
	
	if (!doWrap && doFirst)
		TE32KUpdate(&updateRect,tH);
	
	else if (doWrap) {
		CalParagraph(thisLine,tH,&deltaLines,&numAffected);
		
		if (deltaLines == 0) {
			updateRect = (**tH).viewRect;
			updateRect.top = (**tH).destRect.top + thisLine * (**tH).lineHeight;
			updateRect.bottom = updateRect.top + (**tH).lineHeight * numAffected;
		} else if (deltaLines > 0) {
			LongRectToRect(&((**tH).viewRect),&tempRect);
			tempRect.top = (**tH).destRect.top + (thisLine + numAffected - deltaLines) * (**tH).lineHeight;
			
			GetPort(&oldPort);
			SetPort((**tH).inPort);
	
			updateRgn = NewRgn();
			ScrollRect(&tempRect,0,(**tH).lineHeight * deltaLines,updateRgn);
			DisposeRgn(updateRgn);
			
			SetPort(oldPort);
			
			updateRect = (**tH).viewRect;
			updateRect.top = (**tH).destRect.top + thisLine * (**tH).lineHeight;
			updateRect.bottom = updateRect.top + (**tH).lineHeight * numAffected;
		} else {
			LongRectToRect(&((**tH).viewRect),&tempRect);
			tempRect.top = (**tH).destRect.top + (thisLine - 1 + numAffected) * (**tH).lineHeight;
			
			GetPort(&oldPort);
			SetPort((**tH).inPort);
	
			updateRgn = NewRgn();
			ScrollRect(&tempRect,0,(**tH).lineHeight * deltaLines,updateRgn);
			
			SetPort(oldPort);
#if TARGET_CPU_PPC
			GetRegionBounds (updateRgn, &tempRect);
			updateRect.left = tempRect.left;
			updateRect.top = tempRect.top;
			updateRect.right = tempRect.right;
			updateRect.bottom = tempRect.bottom;
#else
			updateRect.left = (**updateRgn).rgnBBox.left;
			updateRect.top = (**updateRgn).rgnBBox.top;
			updateRect.right = (**updateRgn).rgnBBox.right;
			updateRect.bottom = (**updateRgn).rgnBBox.bottom;
#endif			
			DisposeRgn(updateRgn);
			
			TE32KUpdate(&updateRect,tH);
			
			updateRect = (**tH).viewRect;
			updateRect.top = (**tH).destRect.top + thisLine * (**tH).lineHeight;
			updateRect.bottom = updateRect.top + (**tH).lineHeight * numAffected;
		}
		
		TE32KUpdate(&updateRect,tH);
	}

	TE32KGetPoint((**tH).selStart,&selPt,tH);
	(**tH).selPoint = selPt;
}



#if 0 /* BH: this is not what the original TextEdit autoview does */
void TE32KAutoView(char autoView, TE32KHandle tH)
{
	if (tH) {
		if (!autoView)
			(**tH).clikLoop = NULL;
		else
			(**tH).clikLoop = myClicker;
	}
}
#endif

#if ASCONSOLE
void			TE32KSetEOF (TE32KHandle tH)
{
	if (tH)
		(**tH).consolePos = (**tH).teLength + 1;  /* this should never become smaller than teLength */
}

Boolean			TE32KIsEOF (TE32KHandle tH)
{
	if (tH) 
		return (**tH).consolePos >= (**tH).teLength;
	else
		return true;
}
#endif