/****************************************************************************
**
*W  maccon.c                    GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the console specific functions for the text editor.
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
#include <Dialogs.h>
#include <TextUtils.h>
#include <Windows.h>
#endif

#include "macdefs.h"
#include "macte.h"
#include "macedit.h"
#include "macdocs.h"
#include "maccon.h"
#include "macpaths.h"
#include "macintr.h"

#include "system.h"

#if GAPVER == 4
	#include "sysfiles.h"
#endif

#if GAPVER == 4
extern  UInt            iscomplete_rnam ( Char *     name,
                                     UInt       len );
extern  UInt            completion_rnam ( Char *     name,
                                     UInt       len );

extern  UInt            iscomplete_gvar ( Char *     name,
                                     UInt       len );
extern  UInt            completion_gvar ( Char *     name,
                                     UInt       len );
UInt iscomplete (char * name, UInt len, UInt recname) 
{
	if (recname) 
		return iscomplete_rnam (name, len);
	else
		return iscomplete_gvar (name, len);
}

UInt completion (char * name, UInt len, UInt recname) 
{
	if (recname) 
		return completion_rnam (name, len);
	else
		return completion_gvar (name, len);
}

extern UInt 	SyGaprc;

extern UInt syLastFreeWorkspace;
extern UInt syWorksize;

#elif GAPVER == 3

extern long syLastFreeWorkspace;
extern long syWorksize;


#endif

extern long     SyIsIntrInterval;    /* number of ticks after which to test 
                                        for user interrupt */


/****************************************************************************
**
** 	gPreferencesResRefNum is the file ref num of the file into which the 
**  console's text window state is to be saved, 0 = no file
*/
short gPreferencesResRefNum = 0;

/****************************************************************************
**
** 	consoleHistory contains the last 8192 characters of user input to GAP, 
**	last input line first, separated by '\0' characters. consoleHistoryPtr  
**	points to the line used last
**	consoleHistoryEnd points to the first character after the last 
**	(i.e. oldest) string in the history buffer
*/
char 	consoleHistory[8192];   
char 	* consoleHistoryPtr, * consoleHistoryEnd = consoleHistory;  

/****************************************************************************
**
** 	LogToHelp determins whether GAP 4 should try to print help messages to 
**  a separate window - not fully implemented yet
*/
#if GAPVER == 4
Boolean LogToHelp = false;
#endif

/****************************************************************************
**
** 	gEditorScratch is the minimum of memory required for the editor
**  gMaxLogSize is the amount of memory to be used for the log
**  window.
*/
long gEditorScratch = 32L * 1024L;
long gMaxLogSize = 32L * 1024L;

/****************************************************************************
**
** 	gInsertAlways controls what happens if the user tries to insert something 
**  before the console write position. If InsertAlways is true, the input goes
**  just after the console read position, otherwise an error is signalled 
**  by a system beep
*/
Boolean gInsertAlways = true; 

/****************************************************************************
**
** 	gShowPartialCollection is true if partial garbage collections are also to
**  be shown (if collections are to be shown at all)
*/
Boolean gShowPartialCollection;

/****************************************************************************
**
** 	gGAPIsIdle is true when GAP waits for input, otherwise it is false
*/
Boolean gGAPIsIdle = false;

/****************************************************************************
**
** 	gUserWantsToQuitGAP is true when the 'Quit' menu command is used
*/
Boolean gUserWantsToQuitGAP = false;

/****************************************************************************
**
**  gScrollToPrintout is true if text printed by GAP should always be
**  visible, toggled by window menu item. Output is considerably faster if 
**  gScrollToPrintout is false
*/
Boolean	gScrollToPrintout = true;

/****************************************************************************
**
**  if nonzero, gAboutDocument is the document holding the about box
**
*/
DocumentPtr	gAboutBox = 0;

/****************************************************************************
**
** 	gUseHelpWIndow determins whether the help function should try to use
**  a separate help window, helpLines is the number of lines already output
**  to the help window, helpTitle is used to store the first line of help
**  text, helpActive is true if help text is expected.
*/
#if GAPVER == 4 && HELP_WINDOW

long helpLines;
Str255 helpTitle;
long helpActive = false;

#endif

/****************************************************************************
**
**  gGapOptionsFSSpec contains the FSSpec of the GAP options file (in GAP 3,
**  this was always the GAP folder)
*/
#if GAPVER == 4
FSSpec 				gGapOptionsFSSpec; /* file specs for options file */
#endif

/****************************************************************************
**
** 	TruncateDocument shortens the text in the document window theDocument
**  by deleting lines at the beginning of the document, trying to keep its
**  size below limit.
**
*/
void TruncateDocument (DocumentPtr theDocument, long limit)

{
	TE32KHandle 	tH;
	long 			free, index, i;
#if DEBUG_CONSOLEPOS
	char            * prompt;
#endif
	
	if (!theDocument || !(tH = theDocument->docData) || limit < 0) 
		return;
		
	free = (**tH).teLength - limit;
	if (free <= 0)
		return;
	else if (free < EXTRATEXTBUFF)
		free = EXTRATEXTBUFF; /* free at least that much */
		
	if (free > (**tH).consolePos)
		free = (**tH).consolePos;   /* don't truncate user input */

#if DEBUG_CONSOLEPOS
	prompt = *(**tH).hText + (**tH).promptPos;
#endif
	index = 0;
	while (index < (**tH).nLines && (**tH).lineStarts[index++] < free)
		;
	index--;
	free = (**tH).lineStarts[index];
		
	(**tH).teLength -= free;
		
	BlockMove (*(**tH).hText + free, *(**tH).hText, (**tH).teLength); /* delete text */
		
	for (i = index; i <= (**tH).nLines; i++)   /* update line starts */
		(**tH).lineStarts[i-index] = (**tH).lineStarts[i] - free;

	(**tH).nLines -= index;

	if ((**tH).selStart >= free) 
		(**tH).selStart -= free;
	else 	
		(**tH).selStart = 0;
			
	if ((**tH).selEnd >= free) 
		(**tH).selEnd -= free;
	else 
		(**tH).selEnd = 0;
		
	if ((**tH).undoEnd >= free) 
		(**tH).undoEnd -= free;
	else 
		(**tH).undoEnd = 0;
		
	if ((**tH).undoStart >= free) 
		(**tH).undoStart -= free;
	else 
		(**tH).undoStart = 0;
	
	if ((**tH).consolePos >= free) 
		(**tH).consolePos -= free;
	else 
		(**tH).consolePos = 0;
				
	(**tH).destRect.top += (**tH).lineHeight * index;

	if ((**tH).viewRect.top < (**tH).destRect.top) {  /* if we deleted part of the currently visible window */
		TE32KScroll (0, (**tH).viewRect.top - (**tH).destRect.top, tH);	
	}
		
#if DEBUG_CONSOLEPOS
	prompt = *(**tH).hText + (**tH).promptPos;
#endif

}	

void AppendToHistory ( char * line)
{
	long len;
	
	while (*line == ' ' || *line == TAB)
		line++;
	len = strlen (line);
	
	while (len && (line[len-1] == '\r' || line[len-1] == '\n'))  /* do not insert eols */
		len--;

	if (len) {  /* do not append empty lines */
		if (len >= sizeof (consoleHistory)-1)
			len = sizeof  (consoleHistory) - 1;
		while (consoleHistoryEnd + len + 1 >= consoleHistory + sizeof (consoleHistory) ) {
			consoleHistoryEnd--;
			do   /* delete oldest line in history */
				consoleHistoryEnd--;
			while (consoleHistoryEnd >= consoleHistory && *consoleHistoryEnd != '\0');
			consoleHistoryEnd++;
		}
		BlockMove (consoleHistory, consoleHistory+len+1, consoleHistoryEnd - consoleHistory );
		BlockMove (line, consoleHistory, len);
		consoleHistory[len] = '\0';
		consoleHistoryEnd += len + 1;
	}
}


char * FindInHistory (char * linestart, long len, Boolean forward)
{
	char * p, *l;
	long i;
	
	while (1) {
		p = consoleHistoryPtr;
		if (forward) {
			if (p <= consoleHistory)
				return 0; /* already at the beginning */
			p--; /* skip null character */
			do 
				p--;
			while (p >= consoleHistory && *p != '\0');
			p++;; /* go to first char of string */
		}
		else {
			if (p < consoleHistory) 
				p = consoleHistory;
			else {
				while (*p != '\0') 
					p++;
				p++;  /* go to first char of next string */
				if (p >= consoleHistoryEnd)
					return 0;
			}
		}
		
		consoleHistoryPtr = p;  /* remember that we have used this line */
		l = linestart;
		i = len;
		while (*l == *p && i > 0 && *p != '\0') {
			l++; p++; i--;
		}
		if (i == 0)
			return p;
	}
}

/****************************************************************************
**
**  ConvertGAPKeys converts most of the standard GAP editing keys into their
**  Mac equivalents. Some keys are handled directly by ConvertGAPKeys, and in 
**  this case ConvertGAPKeys returns true.  Otherwise, it only modifies the 
**  message and modifier fields of the EventRecord and returns false to signal 
**  that the key needs further processing. Wherever possible, we do not test 
**  whether the document
**  is read-only but we leave it to the ordinary key handler to produce an 
**  error where desirable.
**  ConvertGAPKeys is called also by the textConvertKey function
**  in macdocs.c
*/

	
#define CTR(C)          ((C) & 0x1F)    /* <ctr> character                */
#define IS_SEP(C)       (!IsAlpha(C) && !IsDigit(C) && (C)!='_')

char lastChar = '\0';   /* last character typed */
long lastChTicks;  /* time when last char typed */
	
Boolean ConvertGAPKeys (DocumentPtr doc, EventRecord * theEventPtr, Boolean readonly)
{
	char ch, *p, *q;
	short mod;
	TE32KHandle tH;
	char buffer [512], buf2 [512];
	long len;
#if! HELP_WINDOW
	TE32KHandle logH;
	long diff;
#endif
	Boolean recname;
	Handle undoBuffer;
	
	if (lastChar == ESCAPE && lastChTicks + 60 > theEventPtr->when) {
		ch = theEventPtr->message&0x1F;
		mod = theEventPtr->modifiers | shiftKey | controlKey;
	}
	else {
		ch = theEventPtr->message&charCodeMask;
		mod = theEventPtr->modifiers;
	}
	if (ch == TAB && !(mod&optionKey)) {
		if (lastChar == TAB && lastChTicks + 60 > theEventPtr->when) 
			mod = mod | shiftKey | controlKey;
		else
			mod = mod | controlKey;
	}
	lastChar = ch;
	lastChTicks = theEventPtr->when;
	if (ch == ESCAPE) 
		return true;
	if (doc && (tH = doc->docData)) {
		if (mod&controlKey) {
			switch (ch) {
				case CTR('C'):	ch = '.'; mod = cmdKey; break;
				case CTR('A'):	ch = LEFTARROW; mod = cmdKey; break;
				case CTR('B'):	ch = LEFTARROW; mod = mod&shiftKey?optionKey:0; break;
				case CTR('F'):	ch = RIGHTARROW; mod = mod&shiftKey?optionKey:0; break;
				case CTR('E'):	ch = RIGHTARROW; mod = cmdKey; break;
				case CTR('H'):	/* actually, this is the same as DELETE on the Mac */
					if (! (mod & shiftKey) || readonly ) {
						ch = DELETE; mod = 0; break;
					}  
					else {
						theEventPtr->message = LEFTARROW; theEventPtr->modifiers = optionKey|shiftKey;
						METHOD_DoKeyDown(doc,theEventPtr);
						METHOD_DoCut(doc);
						return true;
					}
				case CTR('D'):	
					if (mod & shiftKey && !readonly ){/* <esc>-D delete word right */
						theEventPtr->message = RIGHTARROW; theEventPtr->modifiers = optionKey|shiftKey;
						METHOD_DoKeyDown(doc,theEventPtr);
						METHOD_DoCut(doc);
						return true;
					}
					else {
						SysBeep (4);
						return true;
					}
				case CTR('K'):	
					theEventPtr->message = RIGHTARROW; theEventPtr->modifiers = cmdKey|shiftKey;
					METHOD_DoKeyDown (doc,theEventPtr);
					METHOD_DoCut (doc);
					return true;
				case CTR('Y'):	METHOD_DoPaste (doc); return true;   	
				case CTR('T'):
					if (readonly) { /* produce an error message */
						ch = DELETE; mod = 0; break;
					}
					if ((**tH).hText && (**tH).selStart == (**tH).selEnd  
							&& (**tH).selStart > 0
							&& (**tH).selStart < (**tH).teLength ) {
						if (!(undoBuffer = NEWHANDLE (2)) || MEMERROR ()) {
							doMessage (1);  /* out of memory */
							return true;
						}
						p = (*(**tH).hText + (**tH).selStart-1);
						q = *undoBuffer;
						ch = *q++ = *p++;
						*q = *p;
						theEventPtr->message = DELETE; theEventPtr->modifiers = 0;
						METHOD_DoKeyDown (doc,theEventPtr);
						theEventPtr->message = RIGHTARROW; theEventPtr->modifiers = 0;
						METHOD_DoKeyDown (doc,theEventPtr);
						TE32KInsert (&ch, 1, tH);
						METHOD_DoKeyDown (doc,theEventPtr);
						theEventPtr->message = LEFTARROW; theEventPtr->modifiers = 0;
						METHOD_DoKeyDown (doc,theEventPtr);
						(**tH).undoStart = (**tH).selStart - 1;
						(**tH).undoEnd = (**tH).selStart + 1;
						if ((**tH).undoBuf)
							DisposeHandle ((**tH).undoBuf);
						(**tH).undoBuf = undoBuffer;
						(**tH).resetUndo = true;
						doc->fNeedToSave = true;
					}
					return true;

	            case CTR('U'): /* uppercase word                               */
     	        case CTR('L'): /* lowercase word                               */
					if (!(mod & shiftKey) || readonly) break;
					
					if ((**tH).selStart == (**tH).selEnd) { /* select word right */
						theEventPtr->message = RIGHTARROW; theEventPtr->modifiers = optionKey|shiftKey;
						METHOD_DoKeyDown (doc,theEventPtr);
					}
					if (!(len = (**tH).selEnd - (**tH).selStart))
						return true;
					
					if (len > sizeof (buffer)-1) {
						SysBeep (4);
						return true;
					}	
					if (!(undoBuffer = NEWHANDLE (len))|| MEMERROR ()) {
						doMessage (1);  /* out of memory */
						return true;
					}
					HLock ((**tH).hText);
					HLock (undoBuffer);
					BlockMove (*(**tH).hText + (**tH).selStart, *undoBuffer, len);
					HUnlock (undoBuffer);
					BlockMove (*(**tH).hText + (**tH).selStart, buffer, len);
					HUnlock ((**tH).hText);
					
					p = buffer;
					buffer[len] = '\0';
					switch (ch) {
	            		case CTR('U'): /* uppercase word                               */
							while ( *p!='\0') {
								if ('a' <= *p && *p <= 'z')  *p = *p + 'A' - 'a';
								p++;
		                	}
		                	break;
		            	case CTR('C'): /* capitalize word                              */
								if ('a' <= *p && *p <= 'z') {
									 *p = *p + 'A' - 'a';
									p++;
		            			}
     	        		case CTR('L'): /* lowercase word                               */
							while ( *p!='\0') {
								if ('A' <= *p && *p <= 'Z')  *p = *p + 'a' - 'A';
								p++;
		                	}
		                	break;
					}
					theEventPtr->message = DELETE; theEventPtr->modifiers = 0; /*delete selected text */
					METHOD_DoKeyDown (doc,theEventPtr);
                	TE32KInsert (buffer, len, tH);
                	TE32KSetSelect ((**tH).selStart-len, (**tH).selStart, tH);
					(**tH).undoStart = (**tH).selStart;
					(**tH).undoEnd = (**tH).selEnd;
					if ((**tH).undoBuf)
						DisposeHandle ((**tH).undoBuf);
					(**tH).undoBuf = undoBuffer;
					(**tH).resetUndo = true;
					doc->fNeedToSave = true;
                	return true;

				case TAB:
					if ((**tH).hText) {
						if (readonly || mod&optionKey || (**tH).selEnd == 0 
								|| IS_SEP((*(**tH).hText)[(**tH).selEnd-1]) ) {
							mod = 0; /* user forced ordinary tab */
							break;
						}
						HLock ((**tH).hText);
						p = *(**tH).hText + (**tH).selEnd;
						if ((**tH).selStart == (**tH).selEnd) {
							if ( (q = p) > *(**tH).hText ) do {
          		              	q--;
							} while ( q>*(**tH).hText && (!IS_SEP(*(q-1)) || IS_SEP(*q)));
						} else
							q = *(**tH).hText + (**tH).selStart;
		
						len = p - q;
						if (len >= sizeof (buffer)) { /* keyword or selection too long */
							HUnlock ((**tH).hText);
							SysBeep (4); 
							return true;
						}
						else
							BlockMove (q, buffer, len);
						recname = (q > *(**tH).hText && q[-1] == '.');
						HUnlock ((**tH).hText);
						buffer[len] = '\0';
						if (mod & shiftKey ) {  /* show completions */
#if HELP_WINDOW
							if (!iscomplete (buffer, len, recname)  
							       && !completion (buffer, len, recname)) {
								SysBeep (4); 
								return true;
							}
							if (HELPDOCUMENT.fValidDoc) /* close help window if there was one */
								DoClose (&HELPDOCUMENT, false);
							syHelpHeader ("Completions:", buffer, HELPFID);
#else  						
							/*completions should go before the current line */
							diff = 0;
							logH = LOGDOCUMENT.docData;
							if (logH) {
								while ((**logH).consolePos && !ISEOL ((*(**logH).hText)[(**logH).consolePos-1])) {
									(**logH).consolePos--;
									diff++;
								}
							}
							if (!iscomplete (buffer, len, recname)  
							       && !completion (buffer, len, recname)) {
								SyFputs ("    identifier has no completions\n", 1);
								SysBeep (4); 
								if (logH)
									(**logH).consolePos += diff;
								SelectWindow (LOGDOCUMENT.docWindow);
								return true;
							}
#endif
							do {
								p = buffer + strlen (buffer);
								*p++ = '\n';
								*p-- = '\0';
#if HELP_WINDOW
								SyFputs (buffer, HELPFID);
#else
								SyFputs (buffer, 1);
#endif								
								*p = '\0';
							}
							while (completion (buffer, len, recname));
#if !HELP_WINDOW
							if (logH)
								(**logH).consolePos += diff;
								
							SelectWindow (LOGDOCUMENT.docWindow);
#endif
						}
						else {  /* try to extend keyword */
							if (iscomplete (buffer, len, recname)  
							       || !completion (buffer, len, recname)) {
								SysBeep (4); return true;
							}
							p = buffer; 
							q = buf2;
							do
								*q++ = *p++;
							while (*p != NULL);
							while (completion (buffer, len, recname) && buffer[len] == buf2[len]);
							p = buffer + len;
							q = buf2 + len;
							while (*p && *p == *q) {
								p++;
								q++;
							}
							if (p > buffer + len) {
								TE32KSetSelect ((**tH).selEnd, (**tH).selEnd, tH);
								doc->fHaveSelection = SetSelectionFlag(tH);
								p = buf2 + len;
								len = q -  p;
								TE32KInsert(p, len, tH);
							} 
							else {
 								SysBeep (4); return true;
							}
						}
						return true;
					}
					return false;
				case CTR ('P'): 
					ch = UPARROW; 
				case UPARROW: 
					break;
				case CTR ('N'): 
					ch = DOWNARROW; 
					break;
				case DOWNARROW: 
					break;
/* ctrl-D and ctrl-X are handled by consoleConvertKey */
/* ctr-_ not available, because this is the same as <ctr>-downarrow */
				default:
					SysBeep (4);
					return true;
			}  /* switch */
			theEventPtr->message = theEventPtr->message&~charCodeMask | ch;
			theEventPtr->modifiers = mod;
		} /* if control key */
	} /* if tH */
	return false;
}

/****************************************************************************
**
**  methods for console windows, derived from methods for text windows in 
**  macdocs.c
*/
void consoleDoKeyDown(DocumentPtr doc,EventRecord *theEvent)
{
	char ch, ch2, *p;
	long pos, len;
	TE32KHandle tH;
	Boolean readonly;
	
	if(doc && (tH = doc->docData)) {
		readonly = (**tH).selStart < (**tH).consolePos;  
			/* exception: delete/backspace and (**tH).selStart == (**tH).consolePos; */
		ch=theEvent->message&charCodeMask;
		if (readonly && !(ch == LEFTARROW || ch == RIGHTARROW || ch == UPARROW || ch == DOWNARROW)) {
			if (gInsertAlways) { /* move the cursor to the read position */
				TE32KSetSelect ((**tH).consolePos, (**tH).consolePos, tH);
				doc->fHaveSelection = SetSelectionFlag(tH);
			} else {
				SysBeep (2);
				return;
			}
		}
		if (ch == DELETE && (**tH).selStart == (**tH).consolePos && (**tH).selStart == (**tH).selEnd) 
			SysBeep(4); /* cannot delete backwards */
		else if (theEvent->modifiers&controlKey && (ch == UPARROW || ch == DOWNARROW)) {
			HLock ((**tH).hText);
				
			/* find start of current line */
			if  ((**tH).selStart < (**tH).consolePos)
				TE32KSetSelect ((**tH).consolePos, (**tH).consolePos, tH);
			pos = (**tH).lineStarts[indexToLine ((**tH).selStart, tH)];
			if (pos < (**tH).consolePos)
				pos = (**tH).consolePos; /* make sure we don't try to find the gap> prompt */
			while (pos < (**tH).teLength && ((*(**tH).hText)[pos] == ' ' || ((*(**tH).hText))[pos] == TAB))
				pos++;
			p = FindInHistory (*(**tH).hText+pos, (**tH).selStart - pos,  ch == DOWNARROW || ch == CTR('N'));
			HUnlock ((**tH).hText);
			if (p) {
				if (len = strlen (p)) {
					TE32KSetSelect ((**tH).selStart, (**tH).teLength, tH);
					TE32KDelete( tH);
					TE32KInsert(p,len, tH);
					TE32KSetSelect ((**tH).selStart - len, (**tH).selStart, tH);
					doc->fHaveSelection = SetSelectionFlag(tH);					}
			} else 
				SysBeep (4); /* at the beginning or end of command line history */
		}
		else if (theEvent->modifiers&cmdKey && !(theEvent->modifiers&optionKey) 
				&&(ch == LEFTARROW) && (**tH).selStart >= (**tH).consolePos) {
			if (theEvent->modifiers&shiftKey)
				TE32KSetSelect ((**tH).consolePos, (**tH).selEnd, tH);
			else
				TE32KSetSelect ((**tH).consolePos, (**tH).consolePos, tH);
		doc->fHaveSelection = SetSelectionFlag(tH);
		}
		else {
			if (ch == RETURN && !(theEvent->modifiers&shiftKey)) /* user presses return key */
				while ((**tH).selStart < (**tH).teLength ) {    /* move cursor to end of input */
					TE32KKey (RIGHTARROW, tH, cmdKey);
					if ((**tH).selStart >= (**tH).teLength)
						 break;
					ch2 = *((*(**tH).hText)+(**tH).selStart);
					if (ISEOL (ch2))
						break;
					TE32KKey (RIGHTARROW, tH, 0);
				}
			textDoKeyDown(doc,theEvent);
		}
	}
}


Boolean consoleConvertKey (DocumentPtr doc,EventRecord *theEvent)
{
	TE32KHandle tH;
	char ch;
	
	/* only ctr-x and ctr-D differ from ordinary text documents */
	if((tH=doc->docData ) && theEvent->modifiers&controlKey) {
		ch = theEvent->message&charCodeMask;
		if (ch == CTR ('X') || (ch == CTR ('D')  && SyCTRD)) {
			FlushDocument (doc);
			if (ch == CTR ('D'))
			TE32KInsert ("quit;\r", 6, tH);
			doc->fHaveSelection = 0;
			TE32KSelView (tH);
			METHOD_AdjustScrollBars(&LOGDOCUMENT);
			FlushEvents (keyDownMask|mDownMask|mUpMask, 0);
			return true;
		}
	}
	return textConvertKey (doc, theEvent);
}


Boolean consoleDocMenuCommand(DocumentPtr doc, short menuID, short menuItem, short modifiers)
{
	TE32KHandle tH;
	
	switch(menuID) {
		case EDIT_ID:
			switch(menuItem) {
				case iCut:
					if ((tH = doc->docData) /* cannot cut log */
						&& (**tH).selStart < (**tH).consolePos) {
							SysBeep (4);
							return true;
					}
					break;
				case iPaste:
					if ((tH = doc->docData)
						&& (**tH).selStart < (**tH).consolePos) {
							if (gInsertAlways)
								TE32KSetSelect ((**tH).consolePos, 
									((**tH).selEnd < (**tH).consolePos) ? (**tH).consolePos : (**tH).selEnd, tH );
							else {
								SysBeep (2);
								return true;
							}
						}
					break;
				case iAlign:
				case iShiftRight:
				case iShiftLeft:
					SysBeep (4);
					return true;
				default:
					break;
			}
		default:
			break;
		}
	return textDoDocMenuCommand(doc, menuID, menuItem, modifiers);
}



void consoleAdjustDocMenus (DocumentPtr doc, short modifiers)
{
	TE32KHandle tH;
	
	textAdjustDocMenus (doc, modifiers);
	if (tH = doc->docData) {
		if ((**tH).selStart < (**tH).consolePos) { /* part before consolePos is read-protected */
			DisableItem (EditMenu, iCut);
			if (!gInsertAlways)
				DisableItem (EditMenu, iPaste);
			DisableItem (EditMenu, iClear);
		}
		if ((**tH).undoStart < (**tH).consolePos) 
			DisableItem (EditMenu, iUndo);
	}

	SetMenuItemText (FileMenu, iClose, "\pClear Log");
	EnableItem  (FileMenu, iClose);
	
	DisableItem (FileMenu, iSave);
	DisableItem (FileMenu, iSaveAs);
	DisableItem (FileMenu, iRevert);
	DisableItem (EditMenu, iAlign);
	DisableItem (EditMenu, iShiftRight);
	DisableItem (EditMenu, iShiftLeft);
	DisableItem (EditMenu, iAutoIndent);
	DisableItem (FindMenu, iReplace);
	DisableItem (FindMenu, iReplaceSame);
	DisableItem (FindMenu, iFindLine);

	SetMenuItemText (FileMenu, iRead, (modifiers&shiftKey)?"\pRereadÉ":"\pReadÉ");
	SETMENUABILITY (FileMenu,iRead, gGAPIsIdle);
	SETMENUABILITY (FileMenu,iLogTo, gGAPIsIdle);
}


Boolean consoleReadIntoGAP (DocumentPtr doc, Boolean all, Boolean reread)
{
	char buffer [1024];
	OSErr err;
	StandardFileReply reply;
	
	StandardGetFile (NULL, all?-1:-2, NULL, &reply);
		
	if (reply.sfGood) {
		buffer[0] = '\0';
		if (reread) 
			SyStrncat ((char*)buffer, "Reread(\"", 8);
		else
			SyStrncat ((char*)buffer, "Read(\"", 6);

#if GAPVER == 3
		err = FSSpecToPath (&reply.sfFile, buffer + SyStrlen (buffer), 
			sizeof (buffer)-11, true, false);
#elif GAPVER == 4
		err = FSSpecToPath (&reply.sfFile, buffer + SyStrlen ((const Char*)buffer), 
			sizeof (buffer)-11, true, false);
#endif
		if (err == noErr) {
			SyStrncat (buffer, "\");\n", 4);
			ExecuteGAPCommand (buffer);
		}
		else
			return false;
	}
	return true;
}

void consoleDoResize (DocumentPtr doc, Boolean moved)
{
	textDoResize (doc, moved);
	GetLogWindowSize ();
}

void DoLogTo (void)
{
	char buffer [1024];
	OSErr err;
	StandardFileReply reply;
	
	StandardPutFile ("\pLog GAP session to", "\pGAP log",&reply);
	if (reply.sfGood) {
		buffer[0] = '\0';
		SyStrncat ((char*)buffer, "LogTo(\"", 7);
		err = FSSpecToPath (&reply.sfFile, (char*)buffer+SyStrlen (buffer), 
			sizeof (buffer)-12,true, true);
		if (err == noErr) {
			SyStrncat ((char*)buffer, "\");\n", 4);
			ExecuteGAPCommand ((char*)buffer);
		}
		else
			SysBeep (3);
	}
}


void DoClearLog (DocumentPtr doc)
{
	TE32KHandle tH;
	
	if ((tH = (TE32KHandle)doc->docData) )
		if ((**tH).nLines >= 1) {
			TruncateDocument (doc, (**tH).teLength - (**tH).lineStarts[(**tH).nLines-1]);
			TE32KUpdate (&(**tH).viewRect, tH);
			if ((**tH).selStart < (**tH).consolePos)
				TE32KSetSelect ((**tH).consolePos, (**tH).consolePos, tH);
			TE32KSelView (tH);
			METHOD_AdjustScrollBars (doc);
		}
}		


void consoleDoUndo(DocumentPtr doc)
{
	TE32KHandle tH;
	
	if ((tH = doc->docData) && (**tH).undoStart >= (**tH).consolePos) 
		textDoUndo (doc);
}


#if HELP_WINDOW
Boolean helpDestructor (DocumentPtr doc, Boolean cancancel)
{
#pragma unused (cancancel)

	TE32KHandle tH;
	
	HELPDOCUMENT.fNeedToSave := false;
	return textDestructor (doc, cancancel);
}		

void helpDoKeyDown(DocumentPtr doc,EventRecord *theEvent)
{
	char ch;
	TE32KHandle tH;
	
	if(tH=doc->docData) {
		switch (ch=theEvent->message&charCodeMask) {
			case LEFTARROW: 
			case '<': 
				GET_GAP_HELP ("<"); 	
				break;
			case RIGHTARROW: 
			case '>': 
				GET_GAP_HELP (">"); 	
				break;
			case UPARROW: 
				GET_GAP_HELP ("<<"); 	
				break;
			case DOWNARROW:  	
				GET_GAP_HELP (">>"); 	
				break;
			case '+': 
				GET_GAP_HELP ("+"); 	
				break;
			case '-': 	
				GET_GAP_HELP ("-"); 	
				break;
			case '?': 	
				GET_GAP_HELP ("Help on help"); 	
				break;
			default:
				SysBeep(2);

			}
	}
}

void helpAdjustDocMenus (DocumentPtr doc, short modifiers)
	HELPDOCUMENT.fNeedToSave = false;
	textAdjustDocMenus (doc, modifiers);
	DisableItem (EditMenu, iCut);
	DisableItem (EditMenu, iPaste);
	DisableItem (EditMenu, iClear);
	DisableItem (EditMenu, iUndo);
	DisableItem (FileMenu, iSave);
	DisableItem (FileMenu, iRevert);
	DisableItem (EditMenu, iAlign);
	DisableItem (EditMenu, iShiftRight);
	DisableItem (EditMenu, iShiftLeft);
	DisableItem (FindMenu, iFindLine);
	DisableItem (FileMenu, iRead);
	DisableItem (FileMenu,iLogTo);
}

#endif

Boolean OpenLogWindow ()
{
	TE32KHandle tH;
	Handle oldtH;
	OSErr err;
	long count;
	short fontNum;
	char * p;
	Rect r;
	Str255 numStr;
	
#if GAPVER == 3
	FSSpec gGapOptionsFSSpec;
#endif
	
	if (LOGDOCUMENT.fValidDoc) {
		METHOD_Activate (&LOGDOCUMENT);
		return true;
	}
	count = sizeof (DocumentRecord);
	for (p = (char*)&LOGDOCUMENT; count; count--)
		*p++ = '\0';
	LOGDOCUMENT.fDocType = 'TEXT';
	LOGDOCUMENT.fDocCreator = FCREATOR;
	FSMakeFSSpec (0,0, "\pGAP log", &LOGDOCUMENT.fileSpecs);
	LOGDOCUMENT.fValidFSSpec = false;  /* do not automatically use this filespec */

	AddTextDocumentMethods(&LOGDOCUMENT);		
	if (METHOD_InitDoc(&LOGDOCUMENT)) {
#if TEMPMEM  /* make sure that the log window is stored in application heap */
		if ((oldtH = (Handle)LOGDOCUMENT.docData)) {
			if (err =PtrToHand (*oldtH, (Handle*)&tH, GetHandleSize (oldtH)))
				FatalError ();
			DisposeHandle (oldtH);
			LOGDOCUMENT.docData = tH;
			if ((oldtH = (**tH).hText)) {
				if (err = PtrToHand (*oldtH, &((**tH).hText), GetHandleSize (oldtH)))
					FatalError ();
				DisposeHandle (oldtH);
			}
		}
#endif
		if (!(tH =  LOGDOCUMENT.docData) || !(**tH).hText)
			FatalError ();
		
		/* restore console settings - they are stored in the resource fork of the */
		/* gap options file. Note that we do not restore selection from resource */

#if STATE || MARKS
# if GAPVER
#  if 1  /* save settings for log document in file gap options */
		if (!gPreferencesResRefNum) {
#if GAPVER == 3
			err = FSMakeFSSpec (0,0, "\pgap.options", &gGapOptionsFSSpec);
			if (err == noErr)
				err = FSpOpenRF (&gGapOptionsFSSpec, fsCurPerm, &gPreferencesResRefNum);
#else
			err = FSpOpenRF (&gGapOptionsFSSpec, fsCurPerm, &gPreferencesResRefNum);
#endif
			if (err == fnfErr) {
				FSpCreateResFile(&gGapOptionsFSSpec, FCREATOR, 'TEXT', smSystemScript);
				err=ResError();
				if (err == noErr)
					err = FSpOpenRF (&gGapOptionsFSSpec, fsCurPerm, &LOGDOCUMENT.resourcePathRefNum);
			}
			if(err!=noErr) 
				doMessage(17);
		}
		LOGDOCUMENT.resourcePathRefNum = gPreferencesResRefNum;
#  else /* save settings for log document in application */
		LOGDOCUMENT.resourcePathRefNum = gEditorResRefNum;
#  endif
# endif
		ReadTextDocResourceFork(&LOGDOCUMENT);
#endif

#if STATE						
		if(LOGDOCUMENT.windowState) {
			HLock((Handle)LOGDOCUMENT.windowState);
			(**tH).showInvisibles=(**LOGDOCUMENT.windowState).showInvisibles;
			(**tH).crOnly = !((**LOGDOCUMENT.windowState).wordWrap&2);
			(**tH).wrapToLength = (unsigned char)(**LOGDOCUMENT.windowState).wordWrap&4;
/*			(**tH).autoIndent = (unsigned char)(**LOGDOCUMENT.windowState).wordWrap&1; */
			(**tH).tabChars=(**LOGDOCUMENT.windowState).tabWidth;
			c2pstrcpy (numStr, (**LOGDOCUMENT.windowState).fontName);
			GetFNum (numStr, &fontNum);
			TE32KSetFontStuff(fontNum,(**tH).txFace,(**tH).txMode,(**LOGDOCUMENT.windowState).fontSize,tH);
			HUnlock((Handle)LOGDOCUMENT.windowState);
			r = (**LOGDOCUMENT.windowState).userState;
			(**tH).selStart = 0;
			(**tH).selEnd = 0;
			MoveWindow(LOGDOCUMENT.docWindow,r.left,r.top,true);
			SizeWindow(LOGDOCUMENT.docWindow,r.right-r.left,r.bottom-r.top,false);
			METHOD_DoResize (&LOGDOCUMENT, true);
		} else {
#endif
			SetLogWindowSize (25, 80); /* use default values */
#if STATE						
		}
#endif
		(**tH).autoIndent = false;    
		(**tH).consolePos = 0;  /* read from log document */
		
		
		LOGDOCUMENT.mReadIntoGAP = consoleReadIntoGAP;
		LOGDOCUMENT.mDoKeyDown = consoleDoKeyDown;
		LOGDOCUMENT.mConvertKey = consoleConvertKey;		
		LOGDOCUMENT.mDoResize = consoleDoResize;		
		LOGDOCUMENT.mDoDocMenuCommand=consoleDocMenuCommand;
		LOGDOCUMENT.mAdjustDocMenus = consoleAdjustDocMenus;
		LOGDOCUMENT.mDoUndo = consoleDoUndo;
		
		/* 	we don't need special methods because cut and paste handled by 
		 	consoleDoDocMenuCommand */

		ShowDocWindow(&LOGDOCUMENT);
		AdjustMenus(&LOGDOCUMENT, 0); 
		METHOD_GetContentRect (&LOGDOCUMENT, &r);
		return true;
	}
	else {
		FatalError ();
	}
	return false;
}

/****************************************************************************
**
**  OpenHelpWindow creates a new help window by either clearing the previous 
**  one or opening a new one, in case none is open yet. It returns true if
**  this succeeds, and false otherwise.
*/
#if HELP_WINDOW
Boolean OpenHelpWindow ()
{	
	TE32KHandle tH;
	char * p;
	long count;
	Rect r;
	
	if (HELPDOCUMENT.fValidDoc) { /* if there is already a help window, merely clear it */
		ASSERT ((tH = HELPDOCUMENT.docData) != NULL);
		TE32KSetText (0, 0, tH);  
		TE32KSelView (tH);
		METHOD_AdjustScrollBars (&LOGDOCUMENT);		
		METHOD_FocusOnContent (&HELPDOCUMENT);  
		METHOD_GetContentRect (&HELPDOCUMENT, &r);
		EraseRect (&r);
		return true;
	}		

	count = sizeof (DocumentRecord);
	for (p = (char*)&HELPDOCUMENT; count; count--)
		*p++ = '\0';
	HELPDOCUMENT.fDocType = 'TEXT';
	HELPDOCUMENT.fDocCreator = FCREATOR;
	FSMakeFSSpec (0, 0, "\pGAP help window", &HELPDOCUMENT.fileSpecs);
	HELPDOCUMENT.fValidFSSpec = false;

	AddTextDocumentMethods(&HELPDOCUMENT);		
	AddTextReadOnlyMethods(&HELPDOCUMENT);
	HELPDOCUMENT.mAdjustDocMenus=helpAdjustDocMenus;
	HELPDOCUMENT.mDoKeyDown=helpDoKeyDown;
	
	if (METHOD_InitDoc(&HELPDOCUMENT)) {
		/* make help screen read-only */
		if ((tH = HELPDOCUMENT.docData)) {
			(**tH).crOnly = false;
			(**tH).wrapToLength = false;
			TE32KSetFontStuff(kFontIDGeneva, (**tH).txFace, (**tH).txMode, 10, tH); /* BH: changed geneva to kFontIDGeneva */
			METHOD_DoResize(&HELPDOCUMENT, false);
			ShowDocWindow (&HELPDOCUMENT); 
			AdjustMenus(&HELPDOCUMENT); 
			return true;
		}
	}
	METHOD_Destructor(&HELPDOCUMENT);
	SyFputs ("Error initializing GAP help screen\n", 3);
	return false;
}
#endif

/****************************************************************************
**
**  SetHelpWindowTitle sets the title of a help window
*/
#if HELP_WINDOW
void SetHelpWindowTitle (char * line) 
{
	SetDocWindowTitle (&HELPDOCUMENT, (unsigned char*) line);
	SelectWindow (HELPDOCUMENT.docWindow);
}
#endif

#if GAPVER == 3
void RememberHelpTopic (char* topic)
{
	char* p, * q;
	long index, count;
	Boolean found;
	
    for (index = 0; (index <= syLastIndex) 
    	&& (SyStrcmp (topic, syLastTopics[ index ]) != 0); index++);
	
	found = index <= syLastIndex;
	
	if (index >= LENHELPHISTORY) { /* remove the oldest topic in the history */
		index = 0;
	}
		
	/* if the topic is already in the list, remove it */
	while (index < syLastIndex) {
		p = syLastTopics[ index ];
		q = syLastTopics[ index+1 ];
		while (*q != '\0')
			*p++ = *q++;
		*p = '\0';
		index++;
	} 
	
    syLastIndex = index;
    
    q = syLastTopics[ syLastIndex ];
    count = 0;
    while ( *topic != '\0' && count++ < 63 )  *q++ = *topic++;
    *q = '\0';
	
	if (!found && (syLastIndex + 1 < LENHELPHISTORY))
		syLastTopics[ syLastIndex+1 ][0] = '\0';   /* mark the end of help history */
}
#endif

/****************************************************************************
**
**  ReadString reads a line of length at most maxLength-1 into theLine 
**	returns line if string is valid, otherwise (char*)0 
*/
static char* ReadString (DocumentPtr theDocument, char* theLine, long maxLength)

{
	long len, pos;
	TE32KHandle tH;
	
	ProcessEvent ();
	if (!theDocument || !theDocument->fValidDoc || !(tH = theDocument->docData) || maxLength < 2)
		return 0; /* no document to read from, or asking for an empty string; signal an error */

	/* look for the end of the first completed line after consolePos */
	pos = (**tH).consolePos;
	while (pos < (**tH).teLength && ISNEOL ((*(**tH).hText)[pos]))
		pos++;
	if (pos >= (**tH).teLength)  /* no complete line end has been found */
		return 0;
	else {
		len = pos - (**tH).consolePos + 1; /* length including '\r' or '\n' */
		/* if theLine is too long, just return part of it */
		if (len >= maxLength)
			len = maxLength - 1; 
	}

	HLock ((**tH).hText);
	BlockMove (*(**tH).hText + (**tH).consolePos, theLine, len);
	HUnlock ((**tH).hText);
	if (theLine[len-1] == '\r')
		theLine[len-1] = '\n'; 
	theLine[len] = '\0';  /* theLine is a C-type string */
		
	(**tH).consolePos += len;
	
	return theLine;
}


/****************************************************************************
**
**  FlushDocument, FlushLog: delete all pending input from window
*/
void FlushDocument (DocumentPtr doc)
{
	TE32KHandle tH;

	if ((tH = doc->docData)) {
		TE32KSetSelect ((**tH).consolePos, (**tH).teLength, tH);  
		TE32KDelete (tH);     /* flush pending input */
		LOGDOCUMENT.fHaveSelection = 0;
		TE32KSelView (tH);
		METHOD_AdjustScrollBars(&LOGDOCUMENT);
		FlushEvents (keyDownMask|mDownMask|mUpMask, 0);
	}
}


void FlushLog ()
{
	FlushDocument (&LOGDOCUMENT);
}


/****************************************************************************
**
**  print a string to a document window; the document is truncated if the 
**  new size would exceed maxLength. If show is true, the window is scrolled 
**  so that the printed string is visible.
*/
void WriteString (DocumentPtr theDocument, const char* theString, long len, Boolean show, 
	Boolean beforeCursor, long maxLength)
{
	TE32KHandle 	tH;
	char 			buffer[256];
	long 			selStart, selEnd, consolePos;
	long 			undoStart, undoEnd;
#if MARKS
	long			undoDelta;
#endif
	Handle			undoBuf;

/* make sure that document is vaild.  */

	if (!theDocument || !(tH = theDocument->docData)) 
		return;

	if (len >= maxLength) 
		TruncateDocument (theDocument, 0);
	else
		TruncateDocument (theDocument, maxLength-len);
		
	selStart = (**tH).selStart;
	selEnd = (**tH).selEnd;
	consolePos = (**tH).consolePos;

	undoStart = (**tH).undoStart;	
	undoEnd = (**tH).undoEnd;		
#if MARKS
	undoDelta = (**tH).undoDelta;	
#endif
	undoBuf = (**tH).undoBuf;		

	(**tH).undoStart = 0;
	(**tH).undoEnd = 0;
#if MARKS
	(**tH).undoDelta = 0;
#endif
	(**tH).undoBuf = 0;
	
	TE32KSetSelect (consolePos, consolePos, tH);

#if DEBUG_CONSOLE
	for (len = 0; len < sizeof (buffer); buffer[len++] = '\0'); 
#endif

	len = 0;
	do {
		while (*theString != '\0' && *theString != '\b' && len < sizeof (buffer)) {
			if (*theString == '\r' || *theString == '\n') 
				buffer[len++] = '\r';
#if 0
			else if (*theString == CTR('G'))
				SysBeep(4);   
#endif
			else if (*theString == '\t' || (unsigned char)*theString >= 32)
				buffer[len++] = *theString;   
			theString++;
		}
		while (*theString == '\b') {
			theString++;
			len--;
		}
		if (len > 0) {
			TE32KInsert (buffer, len, tH); 
		} else if (len < -10) {
		   	TE32KSetSelect ((**tH).selStart + len, (**tH).selStart, tH);
			TE32KDelete (tH);
		} else
			while (len++ < 0)
				TE32KKey (DELETE, tH, 0);
		len = 0;
			
	}
	while (*theString != '\0');
	
	len = (**tH).selStart - consolePos; 
	
	if ((selEnd > consolePos) || (beforeCursor && (selEnd == consolePos))) {
		if  ((selStart > consolePos) || (beforeCursor && (selStart == consolePos)))
			selStart += len;
		selEnd += len;
	}
	if (show)
		TE32KSelView (tH);
	(**tH).consolePos = (**tH).selStart;
	TE32KSetSelect (selStart, selEnd, tH);
	theDocument->fHaveSelection = SetSelectionFlag(tH);
	METHOD_AdjustScrollBars (theDocument);
	if (undoEnd >= consolePos)
		undoEnd += len;
	if (undoStart >= consolePos)
		undoStart += len;
	(**tH).undoStart = undoStart;
	(**tH).undoEnd = undoEnd;
#if MARKS
	(**tH).undoDelta = undoDelta;
#endif
	if ((**tH).undoBuf)
		DisposeHandle ((**tH).undoBuf);
	(**tH).undoBuf = undoBuf;
}

/****************************************************************************
**
** 	ReadFromLog - read line of length at most maxlength - 1 from log window
*/
char *  ReadFromLog (char* line, long maxLength, long fid)   
{
	char *p;
	TE32KHandle tH;
	
	if (fid != 0 && fid != 1 && fid != 2 && fid != 3)
		return 0;
	    	
	if (creditTicks && gAboutBox)
		DoClose (gAboutBox, false);
		
#if HELP_WINDOW && GAPVER == 4
	helpActive = false;
#endif
	
	/* first, see if there is pending input */
	p = ReadString (&LOGDOCUMENT, line, maxLength);
		
	/* if not, read interactively */
	tH = LOGDOCUMENT.docData;
		
	/* scroll log window to input position */
 	if (!p) {
		if ((**tH).consolePos > (**tH).selStart)
		TE32KSetSelect ((**tH).consolePos, (**tH).consolePos, tH);
		TE32KSelView (tH); 
	}

	consoleHistoryPtr = consoleHistory-1;  /* reset history */
    
	gError = false;
	
	while (!p && !gUserWantsToQuitGAP) {
		if (!LOGDOCUMENT.fValidDoc || !tH) {     /* if log isn't open */
	  		OpenLogWindow();  
	  		if (!LOGDOCUMENT.fValidDoc || !(tH=LOGDOCUMENT.docData))
	  			return 0;  /* cannot open log - signal eof) */
	  	}
		GetLogWindowSize ();  /* try to tell GAP the precise window size */

		METHOD_AdjustScrollBars (&LOGDOCUMENT);

		LOGDOCUMENT.fNeedToSave = false;  /* mark log as unchanged */
		
		gGAPIsIdle = true; /* we are waiting for input */

		p = ReadString (&LOGDOCUMENT, line, maxLength);
		
		if (LOGDOCUMENT.fNeedToSave)
			consoleHistoryPtr = consoleHistory-1;  /* reset history */
	}	

	if ((**tH).consolePos > (**tH).undoStart) {
		/* current undo buffer is invalid, so clear it */
		(**tH).resetUndo = true;  
		if ((**tH).undoBuf)
			DisposeHandle ((**tH).undoBuf);
		(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
	}
	
	gGAPIsIdle = false;

	if (!p || gUserWantsToQuitGAP)
		return (char*)0;  /* return EOF */
		
	AppendToHistory (p);

#if GAPVER == 4 && HELP_WINDOW
	if (p && *p == '?') {
		helpActive = true;
		helpLines = 0;
	}
#endif
	return p;
}

#if HELP_WINDOW
/****************************************************************************
**
** 	WriteToHelp - write string to help window if possible, otherwise to log
*/
void            WriteToHelp ( str )
    char *              str;
{	
	TE32KHandle tH;
	char * p;

#if GAPVER == 3	
    if (!HELPDOCUMENT.fValidDoc && !OpenHelpWindow ())
    	WriteToLog (str);   /* try log window instead */
    else {
#endif
		/* discard spurious empty lines at the top of the help window */
 		if (!(tH = HELPDOCUMENT.docData) || !(**tH).teLength) {
			p = str; 
				while (true) {
		   			while (*p == ' ' || *p == '\t') p++;
		   			if (*p != '\n' && *p != '\r')
		 				break;
		   			if (*p++ == '\0')
		   			   return;   /* this was only an empty line */
	    			str = p;
	    		}
 		}
		WriteString (&HELPDOCUMENT, str, strlen (str), false, false,  0x7FFFFFF);  
		HELPDOCUMENT.fNeedToSave = false;
#if GAPVER == 3	
	}
#endif
}
#endif

/****************************************************************************
**
** 	WriteToLog - write string to log window
*/
void            WriteToLog (const char * str )
{	
#if GAPVER == 4 && HELP_WINDOW
	char * p;
	long len;
	
	if (gUseHelpWIndow && helpActive) {
		p = str;
		while (*p)
			p++;
		--p;
		if (ISEOL (*p)) {
			if (helpLines++)
				WriteToHelp (str);
			else { /* just store away the first line, this will be the help window title */
				len = p - str;
				if (len > 255) 
					len = 255;
				BlockMove (str, helpTitle+1, len);
				*helpTitle = len;
			}
			return;
		}
		else
			helpActive = false; /* incomplete line is considered a prompt */
	}
#endif
   if (!LOGDOCUMENT.fValidDoc)   /* if log isn't open */
    	OpenLogWindow();
	WriteString (&LOGDOCUMENT, str, strlen (str), gScrollToPrintout, true, gMaxLogSize);
	LOGDOCUMENT.fNeedToSave = false;
}

/****************************************************************************
**
** 	GetLogWindowSize sets GAP's screen parameters to the current 
**  window size
*/
void GetLogWindowSize ( void )
{   
	long rows, cols;
	Rect r; 
	TE32KHandle tH;

	if (!LOGDOCUMENT.fValidDoc)
		OpenLogWindow ();
		
	if (LOGDOCUMENT.fValidDoc && (tH = LOGDOCUMENT.docData)) {
		
		METHOD_GetContentRect (&LOGDOCUMENT, &r);
		cols = (r.right - r.left)/(**tH).theCharWidths[' '];
		rows = (r.bottom - r.top)/(**tH).lineHeight;
	
		if ( cols < 20 )  cols = 20;
 		if ( 256 < cols )  cols = 256;
		if ( rows < 10 )  rows = 10;
	
	} else { /* something went wrong, use defaults */
		rows = 24;
		cols = 80;
	}

#if GAPVER == 4	
	if (!SyNrRowsLocked)
#endif
		SyNrRows = (unsigned long) rows;
		
#if GAPVER == 4	
	if (!SyNrColsLocked)
		SyNrCols = (unsigned long) cols;
#endif
}


/****************************************************************************
**
** 	SetLogWindowSize sets GAP's log window to the requested size
*/
void SetLogWindowSize ( long newrows, long newcols )
{
	long rows, cols;
	Rect r; 
	TE32KHandle tH;

	if (!LOGDOCUMENT.fValidDoc)
		OpenLogWindow ();
		
	if (!(tH = LOGDOCUMENT.docData))
		return; /* no document text from, should not happen */
		
	METHOD_GetContentRect (&LOGDOCUMENT, &r);
	cols = (r.right - r.left)/(**tH).theCharWidths[' '];
	rows = (r.bottom - r.top)/(**tH).lineHeight;
	if (newrows <= 0)
		newrows = rows;
	if (newcols <= 0)
		newcols = cols;
	if (rows == newrows && cols == newcols)
		return;
	GetWindowPortBounds ( LOGDOCUMENT.docWindow, &r);
	/* we assume that the diffeence between the rect portRect and r is independent of the 
	   actual window size */
	SizeWindow (LOGDOCUMENT.docWindow, 
			r.right-r.left + (newcols - cols) * (**tH).theCharWidths[' '],
			r.bottom-r.top + (newrows - rows) * (**tH).lineHeight,
			false);
	METHOD_DoResize(&LOGDOCUMENT, false);
}	
	
/****************************************************************************
**
** 	GetGAPHelp dislpays GAP's help function for str
*/
void GetGAPHelp (char * str)
{
	char buf[128];
	
	buf[0] = '?';
	buf[1] = '\0';
	SyStrncat (buf, str, sizeof (buf) - 4);
	SyStrncat (buf, "\n", 2);
	ExecuteGAPCommand (buf);
}


pascal OSErr AEExecuteGAPCommandHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
    OSErr err, err2;
    AEDesc theDesc;
    char buffer[1024];
    long len;
    
	err = AEGetParamDesc(messagein, keyDirectObject, typeChar, &theDesc);
	if (err) 
		doMessage(9);
	else if (!MissedAnyParameters(messagein)) {

#if TARGET_CPU_PPC
		len = AEGetDescDataSize (&theDesc);
#else
 		len = GetHandleSize (theDesc.dataHandle);
#endif
		if (len >= sizeof (buffer))
			doMessage (24);
		else {
#if TARGET_CPU_PPC
			AEGetDescData (&theDesc, buffer, sizeof(buffer));
#else
 			HLock (theDesc.dataHandle);
 			BlockMove (*theDesc.dataHandle, buffer, len);
 			HUnlock (theDesc.dataHandle);
#endif
			buffer[len] = '\0';
			ExecuteGAPCommand (buffer);
		}
	}
	if (err2 = AEDisposeDesc(&theDesc)) 
		doMessage(12);
	else
		err2 = err;
	return err2;
}

pascal OSErr AEGetGAPHelpCommandHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
    OSErr err, err2;
    AEDesc theDesc;
    char buffer[128];
    long len;
    
	err = AEGetParamDesc(messagein, keyDirectObject, typeChar, &theDesc);
	if (err) 
		doMessage(9);
	else if (!MissedAnyParameters(messagein)) {
#if TARGET_CPU_PPC
		len = AEGetDescDataSize (&theDesc);
#else
 		len = GetHandleSize (theDesc.dataHandle);
#endif
		if (len >= sizeof (buffer))
			len = sizeof (buffer);

#if TARGET_CPU_PPC
		AEGetDescData (&theDesc, buffer, sizeof(buffer));
#else
 		HLock (theDesc.dataHandle);
 		BlockMove (*theDesc.dataHandle, buffer, len);
 		HUnlock (theDesc.dataHandle);
#endif
		buffer[len] = '\0';
		GET_GAP_HELP (buffer);
	}
	if (err2 = AEDisposeDesc(&theDesc)) 
		doMessage(12);
	else
		err2 = err;
	return err2;
}

/****************************************************************************
**
** 	ExecuteGAPCommand inserts a GAP command into the log window, to be 
**  after the last line which ends with an eol charachter. 
*/
Boolean ExecuteGAPCommand ( char * str)
{
	TE32KHandle tH;
	long readdiff, pos;
	
	tH = LOGDOCUMENT.docData;
	if (!tH) 
		return false;

	/* save readpos and writepos */
	pos = (**tH).teLength;
	do 
		pos--;
	while (pos >= (**tH).consolePos && ISNEOL ((*(**tH).hText)[pos]));
	pos++;
	
	readdiff = (**tH).consolePos - pos; 
	(**tH).consolePos = pos; 
	
	pos = strlen (str);
	WriteString (&LOGDOCUMENT, str, pos, true, true, gMaxLogSize);
	
	if (pos > 0 && ISNEOL (str[pos-1])) {
		WriteString (&LOGDOCUMENT, "\r", 1, true, true, gMaxLogSize);
		pos++;
	}
	/* restore consolePos */
	(**tH).consolePos += readdiff - pos;
	if ((**tH).consolePos < 0)
		(**tH).consolePos = 0;
	return true;
} 
/****************************************************************************
**
** 	creditTicks is used to measure when the GAP banner (credit) window, it 
**  contains the value of TickCount() after which the window is to be closed
**  automatically - a value of 0 is used to signal that the window should 
**  stay open until closed by the user. 
**
*/
long 			creditTicks; 

/****************************************************************************
**
**  OpenAboutBox - initialise a window for the GAP banner, note that 
**  gMacAboutText contains the text to be displayed in the About... box
**  each string is displayed in a line, the font, size, face, l;ine skip
**  are determined by the defines below.
**  
**
*/
#define ABOUT_FONT_ID  kFontIDGeneva /* id of font to be used in About box */
#define ABOUT_FONT_SIZE 9   /* font size to be used in About box */
#define ABOUT_FONT_FACE  normal   /* font face */
#define ABOUT_LINE_SKIP  15   /* line skip, should be at least ABOUT_FONT_SIZE */

static unsigned char * gMacAboutText[] = {
#if TARGET_API_MAC_CARBON
	"\pKernel version: "MACGAPVERS" - Architecture: PPC Carbon - Compiler: "COMPILER" - Date: "DATE,
#else
# if TARGET_CPU_PPC
	"\pKernel version: "MACGAPVERS" - Architecture: PPC - Compiler: "COMPILER" - Date: "DATE,
# else
	"\pKernel version: "MACGAPVERS" - Architecture: 68020 - Compiler: "COMPILER" - Date: "DATE,
# endif
#endif
#if GAPVER == 3 
	"\p© Lehrstuhl D fuer Mathematik, RWTH Aachen, Germany",  
	"\pAlice Niemeyer, Werner Nickel, Martin Schoenert, Johannes Meier, Alex Wegner,", 
	"\pThomas Bischops, Frank Celler, Juergen Mnich, Udo Polis, Thomas Breuer,",
	"\pGoetz Pfeiffer, Hans U. Besche, Volkmar Felsch, Heiko Theissen, Alexander Hulpke,",
	"\pAnsgar Kaup, Akos Seress Erzsebet Horvath, Bettina Eick",
#else
	"\p© School of Mathematical and Computational Sciences,",
    "\pUniversity of St. Andrews, North Haugh, St. Andrews, Fife KY16 9SS, Scotland.",
#endif
	"\pMacintosh port by Burkhard Hšfling",
	"\pFurther Information is available from <http://www.gap-system.org>",
	NULL};

void aboutAdjustDocMenus (DocumentPtr doc, short modifiers)
{
	DisableItem(FileMenu,0);
	DisableItem(EditMenu,0);
	DisableItem(FindMenu,0);
	DisableItem(WindowMenu,0);
#if MARKS
	DisableItem(MarkMenu,0);
#endif
	if (HelpMenu)
		DisableItem(HelpMenu,0);
}


Boolean aboutDestructor (DocumentPtr doc)
{
	Boolean flag;
	
	ReleaseResource ((Handle)doc->docData);
	doc->docData = NULL;  /* in this way, defaultDestructor doesn't try to dispose of it */
	flag = defaultDestructor (doc);
	gAboutBox = 0;
	return flag;
}


void aboutDeactivate (DocumentPtr doc)
{
	aboutDestructor (doc);
}


void aboutEventMethod (DocumentPtr doc,EventRecord *theEvent)
{
	doc->fNeedToSave = false;
	DoClose (doc, false);
}


void aboutDoIdle (DocumentPtr doc)
{
	Rect r;
	
	if (creditTicks && TickCount() > creditTicks && LOGDOCUMENT.fValidDoc) {
		doc->fNeedToSave = false;
		DoClose (doc, false);
	} else {
		METHOD_GetContentRect (doc, &r);
		r.top = r.bottom - 2 * ABOUT_LINE_SKIP;
		METHOD_Draw (doc, &r, false);
	}
}	

unsigned char statusWorkspace[] = "\pfree GAP workspace:";
unsigned char maxWorkspace[] = "\ptotal:";
unsigned char statusEditor[] = "\p  free memory:";
	
void aboutDraw  (DocumentPtr doc, Rect *r, short page)
{
	PicHandle thePic;
	RgnHandle oldClip, newClip;
	short width, vpos;
	Rect view, temp, temp2;
	unsigned char ** p;
	Str255 statusLine;
	short len;
	FontInfo finfo;
	
	if (page) {
		SysBeep (5);
		return;  /* can't print it */
	}
	
	METHOD_FocusOnContent (doc);

	LoadResource ((Handle)doc->docData);  /* thePic is purgeable */
	thePic = (PicHandle) doc->docData;
	temp = (**thePic).picFrame;

	oldClip = NewRgn ();
	GetClip (oldClip);
	newClip = NewRgn ();
	RectRgn (newClip, r);
	SectRgn (newClip, oldClip, newClip);
	SetClip (newClip);
	
	METHOD_GetContentRect (doc, &view);
	vpos = ABOUT_LINE_SKIP;
	

	OffsetRect (&temp, (view.right - view.left 
		- (temp.right - temp.left)) >> 1, vpos);

	if (SectRect (r, &temp, &temp2))
		DrawPicture(thePic, &temp);

	vpos += (**thePic).picFrame.bottom;

	p = gMacAboutText;
	while (*p) {
		width = StringWidth (*p);
		vpos += ABOUT_LINE_SKIP;
		MoveTo ((view.right - view.left - width) >> 1, vpos);
		DrawString (*p);
		p++;
	}
	/* the following piece of code is a bit tricky because NumToString inserts length
	   bytes into statusLine, which are evaluated and then overwritten by spaces */
	len = statusWorkspace[0]+1;
	BlockMove (statusWorkspace, statusLine, len);

	NumToString ((long)(SyStorLimit - syWorksize + syLastFreeWorkspace), statusLine + len);

	statusLine[0] += statusLine[len] + 1;
	statusLine[len] = ' ';
	
	statusLine[++statusLine[0]] = 'K';
	statusLine[++statusLine[0]] = ' ';

	BlockMove (maxWorkspace + 1, statusLine + statusLine[0] + 1, maxWorkspace[0]);
	statusLine[0] += maxWorkspace[0];
	
	len = statusLine[0]+1;
	NumToString (SyStorLimit, statusLine + len);
	statusLine[0] += statusLine[len] + 1;
	statusLine[len] = ' ';
	
	statusLine[++statusLine[0]] = 'K';
	statusLine[++statusLine[0]] = ' ';

	BlockMove (statusEditor + 1, statusLine + statusLine[0] + 1, statusEditor[0]);
	statusLine[0] += statusEditor[0];
	
	len = statusLine[0]+1;	
	NumToString (FreeMem()/1024, statusLine + len);
	statusLine[0] += statusLine[len]+1;
	statusLine[len] = ' ';
	
	statusLine[++statusLine[0]] = 'K';
	
	width = StringWidth (statusLine);
	vpos += 3*ABOUT_LINE_SKIP/2;

	GetFontInfo (&finfo);
	temp.top = vpos - finfo.ascent;
	temp.bottom = vpos + finfo.descent;
	temp.left = r->left;
	temp.right = (view.right - view.left - width) >> 1;
	EraseRect (&temp);

	MoveTo (temp.right, vpos);
	DrawString (statusLine);

	temp.left = temp.right + width;
	temp.right = r->right;

	EraseRect (&temp);

	SetClip (oldClip);
	DisposeRgn (newClip);
	DisposeRgn (oldClip);
}


void OpenAboutBox(long time)
{
	DocumentPtr doc;
	Rect r, view;
	unsigned char ** p;
	PicHandle thePict;
	GDHandle maingd;
	short width;
	
	if (gAboutBox) 
		return;
		
	doc = GetEmptyDocument ();
	if (!doc) {
		doMessage (4);
		return;
	}

	thePict = GetPicture (ABOUT_PICT_ID);
	if (ResError() != noErr) {
		SyFputs ("Internal error: PICT resource missing.\n", 3);
		SysBeep (4);
		return;
	}
	
	doc->fNoGrow = true;
	doc->windResource = ABOUT_PICT_ID;
	doc->mAdjustDocMenus = aboutAdjustDocMenus;
	doc->mDraw = aboutDraw;
	doc->mDoKeyDown = aboutEventMethod;
	doc->mDoContent = aboutEventMethod;
	doc->mDeactivate = aboutDeactivate;
	doc->mDestructor = aboutDestructor;
	doc->mDoIdle = aboutDoIdle;
	
	if (METHOD_InitDoc (doc)) {
		doc->docData = (TE32KHandle) thePict;
		r = (**thePict).picFrame;
		
		METHOD_FocusOnDocument (doc);
		TextFont (ABOUT_FONT_ID);
		TextSize (ABOUT_FONT_SIZE);
		TextFace (ABOUT_FONT_FACE);
		TextMode (srcCopy);
		p = gMacAboutText;
		while (*p) {
			width = StringWidth (*p);
			r.bottom += ABOUT_LINE_SKIP;
			if (width + r.left > r.right)
				r.right = width + r.left;
			p++;
		}
		r.bottom += 3*ABOUT_LINE_SKIP/2; /* for status line */

		OffsetRect (&r, 40, 40);
		InsetRect (&r, -ABOUT_LINE_SKIP, -ABOUT_LINE_SKIP);
		maingd = GetMainDevice ();
		view = (**maingd).gdRect;

		view.top += GetMBarHeight();

		/* move window to alert position in view */		
		MoveWindow (doc->docWindow, (view.left + view.right - r.right + r.left)>> 1, 
			(2*view.top + view.bottom - r.bottom + r.top) / 3, false);
		SizeWindow (doc->docWindow, r.right-r.left, r.bottom - r.top, false);
		ShowWindow (doc->docWindow);
		SelectWindow (doc->docWindow);
		METHOD_GetContentRect (doc, &r);
		METHOD_Draw (doc, &r, false);
		ValidRect (&r);
		if (time) {
			creditTicks = TickCount() + 60*time;
			if (!creditTicks)
				creditTicks = 1;
		} else
			creditTicks = 0;
	}
	gAboutBox = doc;
}
	
	
void NumToMString (long num, Str255 string)
{
	char ch;
	if (num % 1024 == 0) {
		ch = 'K';
		num /= 1024;
		if (num % 1024 == 0) {
			ch = 'M';
			num /= 1024;
		}
	}
	else 
		ch = '\0';
	NumToString (num, string);
	if (ch != '\0')
		string[++string[0]] = ch;
}

Boolean MStringToNum (Str255 string, long * num, Boolean convert)
{
	long i;
	i = 1;
	while (i <= string[0] && string[i] >= '0' && string[i] <= '9')
		i++;
	if (i < string[0]) 
		return false;
	if (i == string[0]) {
		string[0]--;
		StringToNum (string, num);
		string[0]++;
		if (convert && string[i] == 'k' ||  string[i] == 'K')
			*num *= 1024;
		else if (convert && string[i] == 'm' ||  string[i] == 'M')
			*num *= 1024L * 1024;
		else 
			return false;
	}
	else
		StringToNum (string, num);
	return true;
}
	
		


#if GAPVER == 3
/****************************************************************************
**
**  GetOptions interactively obtains GAP options from user in an interactive 
**  dialog. canSyMemory is true when called at startup, i.e. when changing 
**  the workspace size, and lib and help paths still have an effect 
*/
void GetOptions (Boolean canSyMemory)
	
{
	DialogPtr theDialog;
	short itemHit;
	short itemType;
	Handle itemHandle;
	Rect itemRect;
	Str255 buffer;
	Boolean inputOK;
	long newMemory, newIsIntrFreq;
    long fid;
#if GAPVER == 4
	char SyLibname[256];
	long pos;
#endif

	GetUserAttention ();

	newMemory = SyStorMin;
	newIsIntrFreq = SyIsIntrInterval;
	

	theDialog = GetNewDialog (OPTDIALOG_ID, 0, (WindowPtr)-1);
	if (!theDialog || ResError ())
		return;
#if GAPVER == 4
	pos = 0;
	while (pos < sizeof(SyLibname) && SyGapRootPath[pos] != '\0') {
		SyLibname[pos+1] = SyGapRootPath[pos];
		pos++;
	}
	SyLibname[0] = (unsigned char) (pos - 1);
#elif GAPVER == 3
	c2pstr (SyLibname);   /* the Mac OS needs length-prefixed (Pascal) strings */
	c2pstr (SyHelpname);
#endif
    /* enter current values into dialog items */
    
	if (canSyMemory) {
		HideDialogItem (theDialog, iLibnameStatic);
		GetDialogItem (theDialog, iLibname, &itemType, &itemHandle, &itemRect);
		#if DEBUG_DIALOG
			if (itemType != editText) goto error;
		#endif
	}
	else {
		HideDialogItem (theDialog, iLibname);
		GetDialogItem (theDialog, iLibnameStatic, &itemType, &itemHandle, &itemRect);
		#if DEBUG_DIALOG
			if (itemType != statText) goto error;
		#endif
	}
	SetDialogItemText (itemHandle, (unsigned char*)SyLibname);
	
#if GAPVER == 4
		HideDialogItem (theDialog, iHelpnameStatic);
		HideDialogItem (theDialog, iHelpname);
#elif GAPVER == 3
	if (canSyMemory) {
		HideDialogItem (theDialog, iHelpnameStatic);
		GetDialogItem (theDialog, iHelpname, &itemType, &itemHandle, &itemRect);
		#if DEBUG_DIALOG
			if (itemType != editText) goto error;
		#endif
	}
	else {
		HideDialogItem (theDialog, iHelpname);
		GetDialogItem (theDialog, iHelpnameStatic, &itemType, &itemHandle, &itemRect);
		#if DEBUG_DIALOG
			if (itemType != statText) goto error;
		#endif
	}
	SetDialogItemText (itemHandle, (unsigned char*)SyHelpname);
#endif
	
	if (canSyMemory) 
		GetDialogItem (theDialog, iMemory, &itemType, &itemHandle, &itemRect);
	else
		GetDialogItem (theDialog, iMemoryStatic, &itemType, &itemHandle, &itemRect);
	NumToMString (newMemory, buffer);
	SetDialogItemText (itemHandle, buffer);

	GetDialogItem (theDialog, iMaxMemory, &itemType, &itemHandle, &itemRect);
	NumToMString (SyStorLimit - SyStorLimit % 1024, buffer+4);
	buffer[0] = buffer[4]+5;
	buffer[1] = '('; buffer[2] = '1'; buffer[3] = 'M'; buffer[4] = 'É';
	buffer[buffer[0]] = ')';
	SetDialogItemText (itemHandle, buffer);

	GetDialogItem (theDialog, iIntrFreq, &itemType, &itemHandle, &itemRect);
	#if DEBUG_DIALOG
		if (itemType != editText) goto error;
	#endif
	NumToString (60/SyIsIntrInterval, buffer);
	SetDialogItemText (itemHandle, buffer);


	GetDialogItem (theDialog, iGasman, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
	SetControlValue ((ControlHandle)itemHandle, SyGasman?1:0);
	
	if (canSyMemory) 
		HideDialogItem (theDialog, iGaprc);
	else {
		GetDialogItem (theDialog, iGaprc, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
		if (itemType != ctrlItem + chkCtrl) goto error;
#endif
		SetControlValue ((ControlHandle)itemHandle, SyGaprc?0:1);
	}
	GetDialogItem (theDialog, iBanner, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
	SetControlValue ((ControlHandle)itemHandle, SyBanner?1:0);
	
	GetDialogItem (theDialog, iHelpWarnings, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
#if HELP_WINDOW
	SetControlValue ((ControlHandle)itemHandle, SyHelpWarnings?0:1);
#endif
	GetDialogItem (theDialog, iDefault, &itemType, &itemHandle, &itemRect);
	HiliteControl ((ControlHandle)itemHandle, canSyMemory ? 0: 255);
#if !HELP_WINDOW
	HideDialogItem (theDialog, iHelpWarnings);
#endif

defaults:	/* assume that the dialog item list contains the correct values */

	GetDialogItem (theDialog, iGaprc, &itemType, &itemHandle, &itemRect);
	HiliteControl ((ControlHandle)itemHandle, canSyMemory ? 0: 255);
	GetDialogItem (theDialog, iBanner, &itemType, &itemHandle, &itemRect);
	HiliteControl ((ControlHandle)itemHandle, canSyMemory ? 0: 255);

	if (canSyMemory) {
		HideDialogItem (theDialog, iMemoryStatic);
		GetDialogItem (theDialog, iMemory, &itemType, &itemHandle, &itemRect);
		#if DEBUG_DIALOG
			if (itemType != editText) goto error;
		#endif
	}
	else {
		HideDialogItem (theDialog, iMemory);
		GetDialogItem (theDialog, iMemoryStatic, &itemType, &itemHandle, &itemRect);
		#if DEBUG_DIALOG
			if (itemType != statText) goto error;
		#endif
		GetDialogItemText (itemHandle, buffer);
		if (!MStringToNum (buffer, &newMemory, true))
			newMemory = 0;
	}
	
	
	ShowWindow ((WindowPtr) theDialog);

	SetDialogDefaultItem (theDialog, ok);
	SetDialogCancelItem (theDialog, cancel);
	
	if (canSyMemory)
		SelectDialogItemText (theDialog, iMemory, kMaxShort, kMaxShort);
	else
		SelectDialogItemText (theDialog, iIntrFreq, kMaxShort, kMaxShort);

	do {
		ModalDialog (0, &itemHit);          /* let the user modify the dialog fields */   
		GetDialogItem (theDialog, itemHit, 
				&itemType, &itemHandle, &itemRect);
		if (itemType == ctrlItem + chkCtrl) {
			SetControlValue ((ControlHandle)itemHandle,
				1-GetControlValue ((ControlHandle)itemHandle));
		}
		else if (itemHit == cancel) goto exit;
		else if (itemHit == iSaveDefault) {   /* write options to file "gap.options" in the GAP directory */
            if ((fid = SyFopen ("gap.options", "w")) == -1) 
				SysBeep (2);
			else {
				if (newMemory != SyStorLimit) {
					NumToMString (newMemory, buffer);
					p2cstr (buffer);
					SyFputs (" -m ", fid);
					SyFputs ((char*)buffer, fid);
				}
				GetDialogItem (theDialog, iLibname, &itemType, &itemHandle, &itemRect);
				#if DEBUG_DIALOG
					if (itemType != editText) goto error;
				#endif
				GetDialogItemText (itemHandle, buffer);
				p2cstr (buffer);
				SyFputs (" -l ", fid);
				SyFputs ((char*)buffer, fid);

#if GAPVER == 3
				GetDialogItem (theDialog, iHelpname, &itemType, &itemHandle, &itemRect);
				#if DEBUG_DIALOG
					if (itemType != editText) goto error;
				#endif
				GetDialogItemText (itemHandle, (unsigned char*)buffer);
				if (*buffer) {
					p2cstr (buffer);
					SyFputs (" -h ", fid);
					SyFputs ((char*)buffer, fid);
				}
#endif
				NumToMString (60/newIsIntrFreq, buffer);
				p2cstr (buffer);
				SyFputs (" -z ", fid);
				SyFputs ((char*)buffer, fid);

				GetDialogItem (theDialog, iGasman, &itemType, &itemHandle, &itemRect);
				#if DEBUG_DIALOG
					if (itemType != ctrlItem + chkCtrl) goto error;
				#endif
				if (GetControlValue ((ControlHandle)itemHandle))
					SyFputs (" -g", fid);
				
				GetDialogItem (theDialog, iGaprc, &itemType, &itemHandle, &itemRect);
				#if DEBUG_DIALOG
					if (itemType != ctrlItem + chkCtrl) goto error;
				#endif
				if (GetControlValue ((ControlHandle)itemHandle))
					SyFputs (" -r", fid);
				
				GetDialogItem (theDialog, iBanner, &itemType, &itemHandle, &itemRect);
				#if DEBUG_DIALOG
					if (itemType != ctrlItem + chkCtrl) goto error;
				#endif
				if (GetControlValue ((ControlHandle)itemHandle))
					SyFputs (" -b", fid);

				GetDialogItem (theDialog, iHelpWarnings, &itemType, &itemHandle, &itemRect);
				#if DEBUG_DIALOG
					if (itemType != ctrlItem + chkCtrl) goto error;
				#endif
				if (GetControlValue ((ControlHandle)itemHandle))
					SyFputs (" -H", fid);

				SyFclose (fid);
			}
		}
		else if (itemHit == iDefault) {   /* GAP's dialog resource contains defaults */
			DisposeDialog (theDialog);
			GetNewDialog (OPTDIALOG_ID, 0, (WindowPtr)-1);
			newMemory = SyStorLimit;
			goto defaults;
		}
		
		else if (itemHit == iMemory) {
			GetDialogItem (theDialog, iMemory, &itemType, &itemHandle, &itemRect);
			GetDialogItemText (itemHandle, buffer);
			if (!MStringToNum (buffer, &newMemory, true))
				newMemory = 0;
		}
		else if (itemHit == iIntrFreq) {
			GetDialogItem (theDialog, iIntrFreq, &itemType, &itemHandle, &itemRect);
			GetDialogItemText (itemHandle, buffer);
			if (MStringToNum (buffer, &newIsIntrFreq, false)) {
				if (newIsIntrFreq > 0) 
					newIsIntrFreq = 60/newIsIntrFreq;
				}
				else 
					newIsIntrFreq = 0;
		}

	inputOK = (newIsIntrFreq > 0 
				&& (!canSyMemory || (newMemory >= 1024L*1024L && newMemory <= SyStorLimit)));
	GetDialogItem (theDialog, ok, &itemType, &itemHandle, &itemRect);
	HiliteControl ((ControlHandle)itemHandle, inputOK ? 0: 255);
	}
	while (itemHit != ok);

    /* now read the new values out of the corresponding dialog items */
	
	GetDialogItem (theDialog, iLibname, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != editText) goto error;
#endif
	GetDialogItemText (itemHandle, (unsigned char*)SyLibname);

#if GAPVER == 3	
	GetDialogItem (theDialog, iHelpname, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != editText) goto error;
#endif
	GetDialogItemText (itemHandle, (unsigned char*)SyHelpname);
#endif
	
	SyStorMin = newMemory;
	SyIsIntrInterval = newIsIntrFreq;
	
	GetDialogItem (theDialog, iGasman, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
	SyGasman = GetControlValue ((ControlHandle)itemHandle); /* partial option not available */
	
	GetDialogItem (theDialog, iGaprc, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
	SyGaprc = 1 - GetControlValue ((ControlHandle)itemHandle);
	
	GetDialogItem (theDialog, iBanner, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
	SyBanner = GetControlValue ((ControlHandle)itemHandle);
	
#if HELP_WINDOW
	GetDialogItem (theDialog, iHelpWarnings, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
	SyHelpWarnings = !GetControlValue ((ControlHandle)itemHandle);
#endif 
	
#if 0  /* features not yet available */
	GetDialogItem (theDialog, iResize, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
	SyResize = GetControlValue ((ControlHandle)itemHandle);

	GetDialogItem (theDialog, iSystemHeap, &itemType, &itemHandle, &itemRect);
#if DEBUG_DIALOG
	if (itemType != ctrlItem + chkCtrl) goto error;
#endif
	SyUseSystemHeap = GetControlValue ((ControlHandle)itemHandle);
#endif

error:
exit:
	DisposeDialog (theDialog);
	
	p2cstr ((unsigned char*)SyLibname);    /* convert back to null-terminated (C type) strings */
#if GAPVER == 4
	SySetGapRootPath ((char*)SyLibname);
#elif GAPVER == 3
	p2cstr ((unsigned char*)SyHelpname);
#endif
	return;
}
#endif

#if GAPVER == 4
/****************************************************************************
**
**  ModifyOptions interactively obtains GAP options from the user at startup
*/
void ModifyOptions (char* args)
{
	DialogPtr theDialog;
	short itemHit;
	short itemType;
	Handle itemHandle;
	Rect itemRect;
	Str255 buffer;
	short fid;
	long count;
	OSErr err;
	
	GetUserAttention ();
	
	theDialog = GetNewDialog (OPTDIALOG_ID, 0, (WindowPtr)-1);
	if (!theDialog)
		return;
	c2pstr (args);
	GetDialogItem (theDialog, iCmdLine, &itemType, &itemHandle, &itemRect);
	SetDialogItemText (itemHandle, (unsigned char*)args);
	SetDialogDefaultItem (theDialog, ok);
	SetDialogCancelItem (theDialog, cancel);
	do {
		ModalDialog (0, &itemHit);          /* let the user modify the dialog fields */   
		if (itemHit == iSaveDefault) {   /* write options to file "gap.options" in the GAP directory */
             if ((err = FSpOpenDF (&gGapOptionsFSSpec, fsWrPerm, &fid)) == noErr) {
				GetDialogItem (theDialog, iCmdLine, &itemType, &itemHandle, &itemRect);
				GetDialogItemText (itemHandle, buffer);
				count = buffer[0];
				err = FSWrite (fid, &count, buffer + 1);
				if (err == noErr) 
					err = SetEOF (fid, count);
				if (err || count != buffer[0])
					SysBeep (2);
				err = FSClose(fid);
			}
			if (err)
				SysBeep (2);
		}
	}
	while (itemHit != ok && itemHit != cancel);
	if (itemHit == ok) {
		GetDialogItem (theDialog, iCmdLine, &itemType, &itemHandle, &itemRect);
		GetDialogItemText (itemHandle, (unsigned char*)args);
	}
	p2cstr ((unsigned char*)args);
	DisposeDialog (theDialog);
}
#endif

static CInfoPBRec deleteCPB;
static Str31 deleteName;
static OSErr deleteErr;
static short deleteVRef;

static void deleteFolderContents (long dirid)
{
	short n = 1;

	while (true) {
		deleteCPB.hFileInfo.ioFDirIndex = n;	
		deleteCPB.hFileInfo.ioVRefNum = deleteVRef;
		deleteCPB.hFileInfo.ioDirID = dirid;
		deleteCPB.hFileInfo.ioNamePtr = deleteName;
		
		deleteErr = PBGetCatInfo(&deleteCPB, false);  /* get n-th dir entry */
		if (deleteErr != noErr) {
			if (deleteErr == fnfErr)
				deleteErr = noErr;  /* end of directory reached */
			return;
		}
	
		if(((deleteCPB.hFileInfo.ioFlAttrib >> 4) & 0x01) == 1) {/* if it is a folder */
			deleteFolderContents(deleteCPB.hFileInfo.ioDirID);  /* recurse */
			if (deleteErr == noErr)
				deleteErr = HDelete (deleteVRef, dirid, deleteName); /* delete folder */
		} else 
			deleteErr = HDelete (deleteVRef, dirid, deleteName); /* delete file */
		if (deleteErr != noErr)
			n += 1;
	} 
}

OSErr DeleteFolderAndContents (short vref, long dirid)   /* needed to delete tmp folder at exit */
{
	FSSpec folder;
	
	deleteVRef = vref;
	deleteFolderContents (dirid);
	if (deleteErr == noErr)
		if ((deleteErr = FSMakeFSSpec (deleteVRef, dirid, "\p", &folder)) == noErr)
			deleteErr = FSpDelete (&folder);
	return deleteErr;
}

/****************************************************************************
**
**  gMacOSErrDesc contains a translation table from common MacOS error codes
**  to error description strings - from 'Inside Macintosh'.
*/
errdesc gMacOSErrDesc[] = {
	bdNamErr, "Bad file name or volume name",
	fnfErr, "File not found",
	wPrErr, "Hardware volume lock",
	fLckdErr, "File is locked",
	fnOpnErr, "File not open",
	nsvErr, "Volume not found",
	ioErr, "I/O error",
	eofErr, "Logical end-of-file reached",
	dirFulErr,	"File directory full",
	notOpenErr, "AppleTalk is not open",
	dskFulErr, "All allocation blocks on the volume are full",
	posErr, "Attempt to position mark before start of file",
	tmfoErr, "Too many files open",
	vLckdErr, "Software volume lock",
	fBsyErr, "File is busy; one or more files are open; directory not empty or working directory control block is open",
	dupFNErr, "A file with the specified name already exists",
	opWrErr, "File already open for writing",
	paramErr, "Parameter error",
	rfNumErr, "Reference number specifies nonexistent access path; bad working directory reference number",
	gfpErr, "Error during GetFPos",
/*	volOfflinErr, "Volume is offline", */
	permErr, "Attempt to open locked file for writing",
	volOnLinErr, "Specified volume is already mounted and online",
	nsDrvErr, "Specified drive number doesn't match any number in the drive queue",
	noMacDskErr, "Volume lacks Macintosh-format directory",
	extFSErr, "External file system",
	fsRnErr, "Problem during rename",
	badMDBErr, "Bad master directory block",
	wrPermErr, "Read/write permission doesn't allow writing",
	memFullErr, "Insufficient memory available",
	dirNFErr, "Directory not found",
	tmwdoErr, "Too many working directories open",
	badMovErr, "Attempted to move into offspring",
	wrgVolTypErr, "Not an HFS volume",
	volGoneErr, "Server volume has been disconnected",
/*	fsDSIntErr, "Internal file system error",
	fidNotFoundErr, "File ID not found", */
	fidExists, "File ID already exists",
	notAFileErr,"Specified file is a directory",
	diffVolErr,"Files are on different volumes",
	catChangedErr,"Catalog has changed and catalog position record may be invalid",
	sameFileErr, "Files are the same",
	procNotFound, "no eligible process with specified descriptor",
	memFragErr, "not enough room to launch app w/special requirements",
	appModeErr, "memory mode is 32-bit, but application is not 32-bit clean",
	protocolErr, "app made module calls in improper order",
	hardwareConfigErr, "hardware configuration not correct for call",
	appMemFullErr, "application size not big enough for launch",
	appIsDaemon, "app is BG-only, and launch flags disallow this",
	bufferIsSmall, "buffer too small",
	noOutstandingHLE, "no High level event",
	connectionInvalid, "invalid connection",
	noUserInteractionAllowed, "no user interaction allowed ",
/* the remaining error explanationa are guesses only */
	afpAccessDenied, "Access denied",
	afpCantMove, "Can't move file/folder",
	afpDenyConflict, "Access denied",
	afpDirNotEmpty, "Folder not empty",
	afpDiskFull, "Disk full ",
	afpEofError, "End of file reached",
	afpFileBusy	, "File busy (probably used by another application)",
	afpItemNotFound	, "File/folder not found",
	afpLockErr, "File/folder locked",
	afpNoServer, "AppleShare server not found",
	afpObjectExists, "File/folder exists",
	afpObjectNotFound, "File/folder not found",
	afpSessClosed, "AppleShare server closed down",
	afpUserNotAuth, "You don't have enough access privileges",
	afpTooManyFilesOpen, "Too many files open",
	afpServerGoingDown, "AppleShare server closing down",
	afpCantRename, "Can't rename file/folder",
	afpDirNotFound, "Folder not found",
	afpVolLocked, "Volume is read-only",			
	afpObjectLocked, "File/folder is read-only",	
	afpSameObjectErr, "File/folder already exists",	
	afpInsideTrashErr, "File/folder is in the trash",	
	afpCantMountMoreSrvre, "Can't mount more AppleShare servers",
	afpAlreadyMounted, "AppleShare server already mounted",
	noErr, "No error" /* this marks the end of the list */
};

#if !DONT_USE_ANSI_LIB
#if !TARGET_API_MAC_CARBON
#include <console.h>
#endif

/******************************************************************************************
**
**  CodeWarrior allows the ANSI library to use an external interface for console i/o.
**  The following functions provide the interface for the ANSI library - see also the file
**  'console.stubs.c' which is provided with CodeWarrior
*/

short InstallConsole(short fd)
{
#pragma unused (fd)

	return true == OpenLogWindow ();
}

void RemoveConsole(void)
{
}

long WriteCharsToConsole(char *buffer, long n)
{
	WriteString (&LOGDOCUMENT, buffer, n, gScrollToPrintout, true,  gMaxLogSize);
	
	return 0;
}


long ReadCharsFromConsole(char *buffer, long n)
{
#pragma unused (buffer, n)

	return 0;
}


extern char *__ttyname(long fildes)
{
#pragma unused (fildes)
	/* all streams have the same name */
	static char *__devicename = "GAP log";

	if (fildes >= 0 && fildes <= 3)
		return (__devicename);

	return (0L);
}

/* Begin mm 981218 */
/*
*
*    int kbhit()
*
*    returns true if any keyboard key is pressed without retrieving the key
*    used for stopping a loop by pressing any key
*/
int kbhit(void)
{
      return 0; 
}

/*
*
*    int getch()
*
*    returns the keyboard character pressed when an ascii key is pressed  
*    used for console style menu selections for immediate actions.
*/
int getch(void)
{
      return 0; 
}

/*
*     void clrscr()
*
*     clears screen
*/
void clrscr()
{
	return;
}
/* End mm 981218 */

/*     Change record
 *  mm 981218	Added stubs for kbhit(), getch(), and clrscr()
*/


#else
/******************************************************************************************
**
**  for compilers where ANSI functions send their output to some built-in console which 
**  might interfere with GAP, you may try using the code below, which worked well with
**  older versions of CodeWarrior.
**
*/

#if !TARGET_CPU_PPC
#include <setjmp.68K.c> /* setjmp for the PPC is implemented in one of the standard ANSI C
                           header files */
#endif

/******************************************************************************************
**
**  assert is defined in <assert.h> as
**  #define assert(condition) ((condition) ? \
**     ((void) 0) : __std(__assertion_failed)(#condition, __FILE__, __LINE__))
**
*/
#if __MWERKS__ >= 0x1200
void __assertion_failed(const char * condition, const char * testfilename, int lineno)
#else
void __assertion_failed(char * condition, char * testfilename, int lineno)
#endif
{
	unsigned char linestr[15];
	SyFputs ("Internal error. \n", 3);
	SyFputs ("   assert(", 3);
	SyFputs ((char*)condition, 3);
	SyFputs (") failed\n", 3);
	SyFputs ("   in file ",3);
	SyFputs ((char*)testfilename,3);
	SyFputs (" at line ",3);
	NumToString (lineno, linestr);
	linestr[linestr[0]+1] = '\0'; /* make the string at linestr+1 a C string */
	SyFputs ((char*)linestr+1,3); 
	SyFputs(".\n",3);
	SyExit (1);
}

#if TARGET_CPU_PPC /* for 68K Macs, memcpy and strlen are actually defined in <string.h> */

void * memcpy (void * dst, const void * src, size_t len)

{
	BlockMove (src, dst, len);
	return dst;
}


size_t strlen (
    const char *         str )
{
	const char * p = str;
	while (*p++);
		return p - str - 1;
}

#endif 

int     atoi ( const char * p)
{
	int res = 0;
	
	while (*p >= '0' && *p <= '9')
		res = 10*res + (*p++-'0');
	return res;
}

#define ctrl	__control_char
#define motn	__motion_char
#define spac	__space_char
#define punc	__punctuation
#define digi	__digit
#define hexd	__hex_digit
#define lowc	__lower_case
#define uppc	__upper_case
#define dhex	(hexd | digi)
#define uhex	(hexd | uppc)
#define lhex	(hexd | lowc)

unsigned char	__ctype_map[256] = {
	ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, motn, motn, motn, motn, motn, ctrl, ctrl,
	ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl, ctrl,
	spac, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc,
	dhex, dhex, dhex, dhex, dhex, dhex, dhex, dhex, dhex, dhex, punc, punc, punc, punc, punc, punc,
	punc, uhex, uhex, uhex, uhex, uhex, uhex, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc,
	uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, punc, punc, punc, punc, punc,
	punc, lhex, lhex, lhex, lhex, lhex, lhex, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc,
	lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, punc, punc, punc, punc, ctrl,
	uppc, uppc, uppc, uppc, uppc, uppc, uppc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc,
	lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc, lowc,
	punc, punc, punc, punc, punc, punc, punc, lowc, punc, punc, punc, punc, punc, punc, uppc, uppc,
	punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, lowc, lowc,
	punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, uppc, uppc, uppc, uppc, lowc,
	punc, punc, punc, punc, punc, punc, punc, punc, lowc, uppc, punc, punc, punc, punc, lowc, lowc,
	punc, punc, punc, punc, punc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc, uppc,
	punc, uppc, uppc, uppc, uppc, punc, punc, punc, punc, punc, punc, punc, punc, punc, punc, 000
};
#endif

