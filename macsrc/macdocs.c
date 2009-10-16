/****************************************************************************
**
*W  macdocs.c                   GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the methods for text documents used by the text editor and methods for 
**  the clipboard window.
*/
#if !TARGET_API_MAC_CARBON
#include <Lists.h>
#include <AppleEvents.h>
#include <Balloons.h>
#include <files.h>
#include <Fonts.h>
#include <Gestalt.h>
#include <Controls.h>
#if UNIVERSAL_INTERFACES_VERSION >= 0x0330  
	#include <ControlDefinitions.h>
#endif
#include <LowMem.h>
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
#endif

#include "macdefs.h" /* common definitions for C and resource compiler */
#include "macte.h"
#include "macedit.h"
#include "macdocs.h"
#include "maccon.h"
#include "macpaths.h"

#include "system.h"

#include <ctype.h>
#include <stdlib.h>






/****************************************************************************
**
**  null methods
*/
void nullVoidDocumentMethod (DocumentPtr w) { return;}
void nullVoidDocumentEventMethod (DocumentPtr w,EventRecord * e) {return;}
void nullVoidDocumentPointMethod (DocumentPtr w,Point p) {return;}
void nullVoidDocumenBoolMethod (DocumentPtr w, Boolean f) {return;}
long nullLongDocumentMethod (DocumentPtr w) {return 1;}
short nullShortDocumentMethod (DocumentPtr w) {return 0;}
Boolean nullBoolDocumentMethod (DocumentPtr w) {return false;}
Boolean nullBoolDocumentEventMethod (DocumentPtr w, EventRecord * e) {return false;}
Boolean nullBoolDocumentBoolMethod (DocumentPtr w, Boolean f1, Boolean f2) {return false;}

/****************************************************************************
**
**  generic methods for documents
*/
void defaultFocusOnDocument (DocumentPtr doc)
{
	Rect r;
	
	SetPortWindowPort (doc->docWindow);
	SetOrigin(0,0);
	GetWindowPortBounds (doc->docWindow, &r);
	ClipRect(&r);
}

void defaultFocusOnContent (DocumentPtr doc)
{
	Rect r;
	
	SetPortWindowPort (doc->docWindow);
	SetOrigin (doc->hOffset, doc->vOffset);
	METHOD_GetContentRect (doc,&r);
	ClipRect(&r);
}

void defaultGetContentRect (DocumentPtr doc, Rect *r)
{
	GetWindowPortBounds (doc->docWindow, r);
	if(doc->vScroll) 
		r->right -= SCROLLBAR_WIDTH- 1;
	if(doc->hScroll) 
		r->bottom -= SCROLLBAR_WIDTH - 1;
}
	

void nullDraw (DocumentPtr doc,Rect * r,short s)  /*BH: w,r,s inserted */
{
	return;
}



void defaultDoContent (DocumentPtr doc,EventRecord *event)
{
	Rect contents;
	
	METHOD_FocusOnDocument(doc);
	GlobalToLocal(&event->where);
	METHOD_GetContentRect(doc,&contents);
	if(!PtInRect(event->where,&contents))
		ScrollClick(doc,event);
}

void defaultAactivate (DocumentPtr doc)
{
	METHOD_FocusOnDocument(doc);
	if (!doc->fNoGrow)
		DrawGrowIcon(doc->docWindow);
	if( doc->hScroll)
		ShowControl( doc->hScroll);
	if( doc->vScroll)
		ShowControl( doc->vScroll);
	METHOD_AdjustScrollBars (doc);
#if MARKS
	/* Each doc has its own copy of the markMenu */
	DeleteMenu(MARK_ID);
	MarkMenu= doc->markMenu;
	if(MarkMenu)
		InsertMenu(MarkMenu,WINDOW_ID);
	AdjustMenus(doc->docWindow);
#endif
	return;
}

void defaultDeactivate (DocumentPtr doc)
{
	METHOD_FocusOnDocument(doc);
	if (!doc->fNoGrow)
		DrawGrowIcon(doc->docWindow);
	if( doc->hScroll)
		HideControl( doc->hScroll);
	if( doc->vScroll)
		HideControl( doc->vScroll);
	return;
}


void defaultAdjustScrollBars (DocumentPtr doc)
{
	Rect r;
	short dv,  hMax, vMax;
	
	METHOD_GetContentRect(doc,&r);
#if 0
	dh=dv=0;
#endif

	METHOD_FocusOnDocument(doc);
	if(doc->vScroll) {
		vMax = METHOD_GetVertSize(doc) - (r.bottom - r.top);
		if(vMax<0)
			vMax=0;
		if(doc->vOffset>vMax)
			dv = doc->vOffset - vMax;
		SetControlMaximum(doc->vScroll,vMax);
		SetControlValue(doc->vScroll,doc->vOffset);	
	}
	if(doc->hScroll) {
		hMax = METHOD_GetHorizSize(doc) - (r.right - r.left);
		if(hMax<0)
			hMax=0;
#if 0
		if(doc->hOffset>hMax)
			dh = doc->hOffset - hMax;
#endif
		SetControlMaximum(doc->hScroll,hMax);
		SetControlValue(doc->hScroll,doc->hOffset);	
	}
#if 0
	if(dh | dv) {
		METHOD_FocusOnContent(doc);
		InvalRect(&r);
		/* Shut down clip region to empty rectangle before calling
			METHOD_ScrollContents. */
		oldClip = NewRgn();
		GetClip(oldClip);
		SetRect(&r,0,0,0,0);
		ClipRect(&r);
		METHOD_ScrollContents(doc,dh,dv);
		SetClip(oldClip);
		DisposeRgn(oldClip);
	}
#endif
}



void defaultScrollContents (DocumentPtr doc,short dh,short dv) 
{
	RgnHandle updateRgn;
	Rect r;
	
	METHOD_GetContentRect(doc,&r);
	updateRgn = NewRgn();
	ScrollRect(&r,dh,dv,updateRgn);
	
	 doc->hOffset -= dh;
	 doc->vOffset -= dv;
	
	InvalRgn(updateRgn);
	
	DoUpdate (doc);
	
	DisposeRgn(updateRgn);
}

short defaultGetVertPageScrollAmount (DocumentPtr doc)
{
	Rect r;
	METHOD_GetContentRect(doc,&r);
	return r.bottom - r.top - 16;
}

short defaultGetHorizPageScrollAmount (DocumentPtr doc)
{
	Rect r;
	METHOD_GetContentRect(doc,&r);
	return r.right - r.left - 16;
}


	

Boolean defaultOpenDocFile (DocumentPtr doc)
{
	short refnum;
#if MARK || STATE
	short resRefnum;
#endif
	OSErr err;
	FSSpec specs;
	short perm;
	
	specs=doc->fileSpecs;
	if (doc->fReadOnly) 
		perm = fsRdPerm;
	else
		perm = fsRdWrPerm;
	
	err = FSpOpenDF(&specs,perm,&refnum);
	if (err == fnfErr) {	/* file not found, create it */
		err = FSpCreate(&specs,FCREATOR,doc->fDocType, smSystemScript);
		if (err == noErr) 
			err = FSpOpenDF(&specs,perm,&refnum);
	}
	if (!doc->fReadOnly && err) { /* try if we can open the file as read-only */		
		err = FSpOpenDF(&specs,fsRdPerm,&refnum);
		if(err==noErr) { /* tell the user that the file is read-only */
			doMessage(3);
			doc->fReadOnly = true;
		}
	}
	
	if (err) {
		doDiagnosticMessage(13,err);	/* report the error */
		return 0;
	}
	
	/* Successfull open.  */
	
	doc->dataPathRefNum = refnum;

#if MARK || STATE	
	resRefnum=FSpOpenResFile(&specs,fsCurPerm);
/*	resRefnum=HOpenResFile(specs.vRefNum,specs.parID,specs.name,fsRdWrPerm); */
 
 
 /*BH: cleaned up the rest of this routine, which used to change refnum */
	
	if(resRefnum == -1) { 
		/* No resource fork for this file. */
		resRefnum=0;
		if(!doc->fReadOnly) {
		
			FSpCreateResFile(&specs, FCREATOR, doc->fDocType, smSystemScript); 
			     /*BH: type and creator seem to be the same as for data fork */
			err=ResError();
			if(err!=noErr) {
				doMessage(17);
			} else {
				resRefnum=FSpOpenResFile(&specs,fsCurPerm);
				if(resRefnum==-1) {
					resRefnum=0;
					doMessage(17);
					/* Can't create it. Forget this. */
				}
			}
		}
	} 	
	
	doc->resourcePathRefNum=resRefnum;
#endif		
	return refnum;
}

short defaultGetLineScrollAmount (DocumentPtr w) {return 16;}

Boolean defaultInitDoc (DocumentPtr doc) {
	Rect r;
	GDHandle mainGD;
	short n;
	
	n = CountDocuments ();
	SetRect(&r,	gDefaultDocRect.left+10*n,   /*BH: now usess gDefaultDocRect; use same values as StackWindows () */
				gDefaultDocRect.top+20*n,
				gDefaultDocRect.right+10*n,
				gDefaultDocRect.bottom+20*n);

	mainGD=GetMainDevice();
	SectRect (&(**mainGD).gdRect, &r, &r);
	
	if ((r.right-r.left)>(1024+15)) r.right=r.left+1024+15;
	if ((r.bottom-r.top)>(1024+15)) r.bottom=r.top+1024+15;
	if(!((r.right-r.left)%2)) r.right--;
	if(!((r.bottom-r.top)%2)) r.bottom--;

	if(doc->windResource) 
		doc->docWindow=(gHasColorQD)?  GetNewCWindow(doc->windResource, NULL, (WindowPtr)-1L) :
								GetNewWindow(doc->windResource, NULL, (WindowPtr)-1L) ;
	else
		doc->docWindow=(gHasColorQD)?  NewCWindow(NULL, &r,"\p",false,zoomDocProc, (WindowPtr)-1L,true,0) :  /*BH: "" string must be Pascal */
								NewWindow(NULL, &r,"\p",false,zoomDocProc, (WindowPtr)-1L,true,0);  /*BH: "" string must be Pascal */
	if(!doc->docWindow)
		return 0;
	if(*(doc->fileSpecs.name))
		SetDocWindowTitle(doc, doc->fileSpecs.name);	
	doc->fValidDoc=true;	/* mark the window as valid */
	return true;
}

Boolean defaultDestructor (DocumentPtr doc)
{
#if MARKS
	Handle mH;
#endif
	
	if( doc->docWindow) 
		DisposeWindow(doc->docWindow);
	doc->docWindow = 0;
	
#if MARKS
	mH=Get1Resource('MENU',MARK_ID);
	if(mH) {
		MarkMenu=(MenuHandle)mH;
		DeleteMenu(MARK_ID);
		InsertMenu(MarkMenu,WINDOW_ID);
	}
	
	if( doc->marks)
		DisposeHandle( doc->marks);
	if( doc->markMenu)
		DisposeHandle((Handle) doc->markMenu);
	 doc->markMenu=0;
#endif
#if STATE
	if( doc->windowState)
		DisposeHandle((Handle) doc->windowState);
	 doc->windowState=0;
#endif

	if( doc->docData)
		DisposeHandle( (Handle) doc->docData);
	 doc->fValidDoc=false;
	 doc->docData=0;
	 return true;
}
			

void defaultAdjustDocMenus (DocumentPtr doc, short modifiers)
{
	
	/* File Menu */
	EnableItem(FileMenu,iClose);
	SETMENUABILITY(FileMenu,iSave,doc->fNeedToSave);
	EnableItem(FileMenu,iSaveAs);
	EnableItem(FileMenu,iSaveACopy);
	SETMENUABILITY(FileMenu,iRevert,doc->fNeedToSave);
	SETMENUABILITY(FileMenu,iPageSetup, gPrintBufferSize);
	SETMENUABILITY(FileMenu,iPrint, gPrintBufferSize);
	
	/* Edit Menu */
	SETMENUABILITY(EditMenu,iUndo,doc->fNeedToSave);
	
	SETMENUABILITY(EditMenu,iCut,doc->fHaveSelection);
	SETMENUABILITY(EditMenu,iCopy,doc->fHaveSelection);
	EnableItem(EditMenu,iPaste);
	SETMENUABILITY(EditMenu,iClear,doc->fHaveSelection);

	EnableItem(FileMenu,0);
	EnableItem(EditMenu,0);
	EnableItem(FindMenu,0);
#if MARKS
	EnableItem(MarkMenu,0);
#endif
	EnableItem(WindowMenu,0);
#ifdef GAPVER
	if (HelpMenu)
		EnableItem (HelpMenu, 0);	
#endif
}



Boolean defaultDoDocMenuCommand (DocumentPtr w, short s, short t, short u) /*BH: w, s, t, u inserted */
{	return false; }


void AddDefaultDocumentMethods (DocumentPtr doc)
{
	doc->mInitDoc=defaultInitDoc;
	doc->mOpenDocFile=defaultOpenDocFile;
	doc->mDestructor=defaultDestructor;
	doc->mReadIntoGAP=nullBoolDocumentBoolMethod;
	/* Event actions */
	doc->mDraw=nullDraw;
	doc->mActivate=defaultAactivate;
	doc->mDeactivate=defaultDeactivate;
	doc->mDoContent=defaultDoContent;
	doc->mDoKeyDown=nullVoidDocumentEventMethod;
	doc->mConvertKey=nullBoolDocumentEventMethod;
	doc->mDoIdle=nullVoidDocumentMethod;
	doc->mAdjustCursor=nullVoidDocumentPointMethod;
	doc->mDoResize=nullVoidDocumenBoolMethod;
	
	/* Edit menu and clipboard functions */
	doc->mDoDocMenuCommand=defaultDoDocMenuCommand;
	doc->mAdjustDocMenus=defaultAdjustDocMenus;
	doc->mDoCut=nullVoidDocumentMethod;
	doc->mDoCopy=nullVoidDocumentMethod;
	doc->mDoPaste=nullVoidDocumentMethod;
	doc->mDoClear=nullVoidDocumentMethod;
	doc->mDoSelectAll=nullVoidDocumentMethod;
	doc->mDoUndo=nullVoidDocumentMethod;
	
	doc->mReadDocFile=nullBoolDocumentMethod;
	doc->mWriteDocFile=nullBoolDocumentMethod;
	
#if MARKS || STATE
	doc->mWriteDocResourceFork=nullBoolDocumentMethod;
#endif
	
	doc->fDocType='????';

	doc->mDoPageSetup=nullVoidDocumentMethod;
	doc->mDoPrint=nullVoidDocumentMethod;
	
	/* Scrolling methods */
	doc->mAdjustScrollBars=defaultAdjustScrollBars;
	doc->mFocusOnContent=defaultFocusOnContent;
	doc->mFocusOnDocument=defaultFocusOnDocument;
	doc->mGetVertSize=nullShortDocumentMethod;
	doc->mGetHorizSize=nullShortDocumentMethod;
	doc->mGetVertLineScrollAmount=defaultGetLineScrollAmount;
	doc->mGetHorizLineScrollAmount=defaultGetLineScrollAmount;
	doc->mGetVertPageScrollAmount=defaultGetVertPageScrollAmount;
	doc->mGetHorizPageScrollAmount=defaultGetHorizPageScrollAmount;
	
	doc->mDisplaySelection=nullVoidDocumentMethod;
	doc->mScrollContents=defaultScrollContents;
	doc->mGetContentRect=defaultGetContentRect;
}

/****************************************************************************
**
**  Methods for clipboard
*/
Boolean clipboardDestructor(DocumentPtr doc)
{
	Str255 clipName;

	if (textDestructor(doc)) {
		gClipboardDoc = 0;
		GetIndString(clipName,129,3);
		SetMenuItemText(EditMenu,iShowClipboard,clipName);
		return true;
	}
	return false;
}

void clipboardDeactivate(DocumentPtr doc)
{
	clipboardDestructor (doc);
}

void clipboardAdjustDocMenus(DocumentPtr doc, short modifiiers) 
{
	
	/* File Menu */
	EnableItem(FileMenu,iClose);
	
	DisableItem(FileMenu,iSave);
	DisableItem(FileMenu,iSaveAs);
	DisableItem(FileMenu,iSaveACopy);
	DisableItem(FileMenu,iRevert);
	DisableItem(FileMenu,iPageSetup);
	DisableItem(FileMenu,iPrint);
		
	/* Edit Menu */
	DisableItem(EditMenu,iUndo);
	DisableItem(EditMenu,iCut);
	DisableItem(EditMenu,iCopy);
	DisableItem(EditMenu,iPaste);	
	DisableItem(EditMenu,iClear);
	DisableItem(EditMenu,iSelectAll);
	EnableItem(EditMenu,iShowClipboard);
		
	DisableItem(EditMenu,iAlign);
	DisableItem(EditMenu,iShiftRight);
	DisableItem(EditMenu,iShiftLeft);
	
	EnableItem(FileMenu,0);
	EnableItem(EditMenu,0);
	DisableItem(FindMenu,0);
#if MARKS
	DisableItem(MarkMenu,0);
#endif
	EnableItem(WindowMenu,0);
}

void clipbooardDoContent(DocumentPtr doc,EventRecord *event)
{
	Rect contents;

	METHOD_FocusOnDocument(doc);
	GlobalToLocal(&event->where);
	METHOD_GetContentRect(doc,&contents);
	if(!PtInRect(event->where,&contents))
		ScrollClick(doc, event);
}

void clipboardDoIdle(DocumentPtr doc)
{
	TE32KHandle tH;
		
	if(tH = gClipboardDoc->docData)
		if((**tH).caretState)
			xorCaret(tH);
}

DocumentPtr OpenClipboardWindow(void)
{
	DocumentPtr doc;
	TE32KHandle tH;
	Rect wRect;
	Str255 clipTitle;
	GDHandle mainGD;
	
	GetIndString(clipTitle,129,5);			/* "Clipboard" */
	if(doc = GetEmptyDocument()) {
		AddTextDocumentMethods (doc);
		if (METHOD_InitDoc (doc)) {
			/* clipboard specific methods */
			doc->mDoKeyDown=nullVoidDocumentEventMethod;
			doc->mConvertKey=nullBoolDocumentEventMethod;
			doc->mDoCut=nullVoidDocumentMethod;
			doc->mDoCopy=nullVoidDocumentMethod;
			doc->mDoPaste=nullVoidDocumentMethod;
			doc->mDoClear=nullVoidDocumentMethod;
			doc->mDoUndo=nullVoidDocumentMethod;
			doc->mWriteDocFile=nullBoolDocumentMethod;
			doc->mDestructor=clipboardDestructor;
			doc->mDeactivate=clipboardDeactivate;
			doc->mAdjustDocMenus=clipboardAdjustDocMenus;
			doc->mDoContent=clipbooardDoContent;
			doc->mDoIdle=clipboardDoIdle;

			/* Make the default a non-wrapping window. */
			tH = doc->docData;
			(**tH).crOnly=true;
			(**tH).wrapToLength=false;
			/* Make it a low, wide window on the bottom of the screen. */
			mainGD=GetMainDevice();
			wRect = (**mainGD).gdRect;

			InsetRect (&wRect, 4, 4);
			wRect.top = wRect.bottom - 130;
			MoveWindow (doc->docWindow, wRect.left, wRect.top, true);
			SizeWindow (doc->docWindow,wRect.right - wRect.left, wRect.bottom - wRect.top, false);
			METHOD_DoResize(doc, true);
			
			TE32KPaste(tH);
			SetDocWindowTitle(doc, clipTitle);
			ShowDocWindow(doc);
			GetIndString(clipTitle,129,4);
			SetMenuItemText(EditMenu,iShowClipboard,clipTitle);
			InitCursor();
			AdjustMenus(doc, 0);  /*BH: inserted */
			return doc;
		} else
			METHOD_Destructor(doc);
	}
	return 0;
}

/****************************************************************************
**
**  auxiliary functions for text windows
*/
short SetSelectionFlag(TE32KHandle tH)
{
	long cr;
	
	if((**tH).selStart < (**tH).selEnd) {
		cr=Munger((**tH).hText,(**tH).selStart,"\n",1L,0,0);
		if(cr<0 || cr>=(**tH).selEnd)
			return 1;	/* no '\n' in selection range */
		return -1;		/* \n in selection range. */
	}
	return 0;			/* no selection range */
}


static long DoLineDialog (long max, long current)
{
	short itemHit;
	short itemType;
	Handle itemHandle;
	Rect itemRect;
	Str255 buffer;
	long line,i;
	DialogPtr theDialog;
	
	theDialog = GetNewDialog (LINEDIALOG_ID, 0, (WindowPtr)-1);
	if (!theDialog)
		return -1;
	GetDialogItem (theDialog, iLineNo, &itemType, &itemHandle, &itemRect);
	NumToString (current, buffer);
	SetDialogItemText (itemHandle, buffer);
	SelectDialogItemText (theDialog, iLineNo, 0, kMaxShort);
	SetDialogDefaultItem (theDialog, ok);
	SetDialogCancelItem (theDialog, cancel);
	ShowWindow (GetDialogWindow (theDialog));
	line = current; /* no valid line number entered yet */

	do {
		GetDialogItem (theDialog, ok, &itemType, &itemHandle, &itemRect);
		HiliteControl ((ControlHandle)itemHandle, line > 0 && line <= max ? 0: 255);
		ModalDialog (0, &itemHit);
		GetDialogItem (theDialog, itemHit, &itemType, &itemHandle, &itemRect);
		if (itemHit == iLineNo) {
			GetDialogItem (theDialog, iLineNo, &itemType, &itemHandle, &itemRect);
			GetDialogItemText (itemHandle, buffer);
			line = 0;
			for (i=1; i <= buffer[0] && line >= 0; i++) {
				if (buffer[i] >= '0' && buffer[i] <= '9')
					line = line * 10 + buffer[i]-'0';
				else
					line = -1;
			}
		}
	}
	while (!((itemHit == ok && line > 0 && line <= max) || itemHit == cancel ));
	
	DisposeDialog (theDialog);
	return line;
}


static long VirtualEntabALine(StringPtr p,long *nTabs,long *nSpaces,long tabChars)
{
	long nT=0,nS=0,tabCnt;
	StringPtr q;
	
	q=p;
	while(isspace(*p) && ISNEOL (*p)) {
		if(*p==TAB) {
			tabCnt=tabChars;
			nS=0;
			nT++;
		} else if(*p==' ') {
			if(!--tabCnt) {
				tabCnt=tabChars;
				nT++;
				nS=0;
			} else
				nS++;
		}
		p++;
	}
	*nTabs=nT;
	*nSpaces=nS;
	return p-q;	/* return count to first nonspace */
}


static void EnTabAndShift(DocumentPtr doc, short direction)
{
	StringPtr q;
	long line,lastLine,tabChars,nMoved,position;
	long selStart,selEnd,len,whiteSpace,delta,newLen;
	long teBufLen;
	long nAlignTabs,nAlignSpaces,nTabs,nSpaces;
	TE32KHandle tH;
	Handle newText;
	LongPoint pt;
	Rect box;
	
	if(tH= doc->docData) {
		selStart=(**tH).selStart;
		selEnd=(**tH).selEnd;
		len=(**tH).teLength;
		
		if((**tH).undoBuf)
			DisposeHandle((**tH).undoBuf);

		(**tH).resetUndo = true;  /*BH: changed to true */
#if MARKS
		(**tH).undoDelta = 0;
#endif
		(**tH).undoBuf=NEWHANDLE(selEnd-selStart);
		
		if (MEMERROR() || (**tH).undoBuf==NULL) {
			(**tH).undoBuf = NULL;
			(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
			if (!doConfirmDialog(7,"\p"))
				return;
		} else {
			HLock((**tH).undoBuf);
			HLock((**tH).hText);
			BlockMove(*((**tH).hText) + selStart,*(**tH).undoBuf,selEnd-selStart);
			HUnlock((**tH).undoBuf);
			HUnlock((**tH).hText);
		}
		
		teBufLen=GetHandleSize((**tH).hText);
		tabChars=(**tH).tabChars;

		HLock((Handle)tH);
		HLock((**tH).hText);
		
		line = indexToParagraph(selStart,tH);
		selStart = (**tH).lineStarts[line];

		lastLine = indexToLine(selEnd,tH);
		if(selEnd > (**tH).lineStarts[lastLine])
			selEnd = (**tH).lineStarts[++lastLine];
		
		nMoved=0;

		if(direction == 0) {
			position=(**tH).lineStarts[line++];
			q=(unsigned char *) *(**tH).hText + position;
			
 			whiteSpace=VirtualEntabALine(q,&nAlignTabs,&nAlignSpaces,tabChars);		
		}
		
		for(;line<lastLine;line++) {
			position=(**tH).lineStarts[line]+nMoved;
			q=(unsigned char *) *(**tH).hText + position;
			if((**tH).crOnly || ISEOL(*(q-1)) ) {
 				whiteSpace=VirtualEntabALine(q,&nTabs,&nSpaces,tabChars);		
			
				if(direction==1)
					nTabs++;
				else if(direction==-1) {
					if(nTabs)
						nTabs--;
					if(!nTabs) {			/* number of spaces after last tab set to zero if no tab */
						nSpaces -= (**tH).tabChars;
						if (nSpaces < 0)
							nSpaces = 0;
					}
				} else {
					nTabs = nAlignTabs;
					nSpaces = nAlignSpaces;
				}
				
				delta = nTabs + nSpaces - whiteSpace; /* if (nTabs + nSpaces - whiteSpace) < 0 then Block move left */
			
				newLen = len + delta;
			
				nMoved += delta; 

				selEnd += delta;
			
				if (teBufLen < newLen) {
					HUnlock((**tH).hText);
					HUnlock((Handle)tH);
					SetHandleSize((**tH).hText,newLen + 256);
					teBufLen=GetHandleSize((**tH).hText);
					if (MEMERROR() || teBufLen < newLen) {
						newText=NEWHANDLE(newLen + 256);
						if(!newText|| MEMERROR ()) {
							doMessage(1);
							return;
						}
						teBufLen=GetHandleSize((**tH).hText);
						HLock((**tH).hText);
						HLock(newText);
					
						BlockMove(*((**tH).hText),*newText,teBufLen);
					
						HUnlock((**tH).hText);
						HUnlock(newText);
						DisposeHandle((**tH).hText);
						(**tH).hText=newText;
					}
					HLock((Handle)tH);
					HLock((**tH).hText);
					q=(unsigned char *) *(**tH).hText + position;			
				}
			
				if(delta) { 
					BlockMove(q+whiteSpace,q+nTabs+nSpaces,len-position-whiteSpace);
#if MARKS
					UpdateMarks(doc,position+nTabs+nSpaces,position+whiteSpace,delta,(**tH).teLength);
#endif
				}
#if ASCONSOLE
				if ((**tH).consolePos >= position+whiteSpace)
					(**tH).consolePos += delta;
#endif
				(**tH).selEnd += delta;
							
				while(nTabs-- > 0)
					*q++ = TAB;
				while(nSpaces-- > 0)
					*q++ = ' ';
			
				len = newLen;
			}
		}

		HUnlock((**tH).hText);
		HUnlock((Handle)tH);
		(**tH).undoStart = selStart;
		(**tH).undoEnd = selEnd;
		doc->fNeedToSave = true;

		(**tH).teLength=len;
		
		SetTE32KRect(doc);

		SetPortWindowPort (doc->docWindow);
		METHOD_GetContentRect(doc,&box);
		TE32KGetPoint (selStart, &pt, tH);
		pt.v -= (**tH).fontAscent;
		if (pt.v < -32767)
			box.top = -32767;
		else if (pt.v > 32767)
			box.top = 32767;
		else
			box.top = pt.v;
			
		if ((**tH).crOnly) { /* otherwise the indented region may wrap */
			TE32KGetPoint (selEnd, &pt, tH);
			pt.v += (**tH).lineHeight - (**tH).fontAscent;
			
			pt.v -= (**tH).fontAscent;
			if (pt.h < -32767)
				box.bottom = -32767;
			else if (pt.v > 32767)
				box.bottom = 32767;
			else
				box.bottom = pt.v;
		}
		
		InvalRect(&box);
		EraseRect(&box);
	}
}


static Boolean InitScrollDoc (DocumentPtr doc)
{
	if (doc->docWindow) {
		SetPortWindowPort (doc->docWindow);
		doc->hScroll = GetNewControl(128,doc->docWindow);
		doc->vScroll = GetNewControl(129,doc->docWindow);
		doc->fNoGrow = false;
		if ( doc->hScroll && doc->vScroll) {
			SizeScrollBars(doc);
			METHOD_AdjustScrollBars(doc);
			return true;
		}
	}
	return false;
}


static void ScrollClick (DocumentPtr doc, EventRecord *event)
{
	ControlHandle whichControl;
	short part;
	
	METHOD_FocusOnDocument(doc);
	
	if(part = FindControl(event->where,doc->docWindow,&whichControl)) {
		switch (part) {  /*BH: replaced part constants by new names */
			case kControlIndicatorPart:
				DoThumbScroll(doc, whichControl,event->where);
				break;
			case kControlUpButtonPart:
			case kControlDownButtonPart:
				DoButtonScroll(doc, whichControl,event->where);
				break;
			case kControlPageUpPart:
			case kControlPageDownPart:
				DoPageScroll(doc, whichControl, part);
				break;
			default:
				break;
		}
	}
}


static void DoButtonScroll(DocumentPtr doc, ControlHandle theControl,Point localPt)
{
	gCurrentDocument=doc;
	if(theControl==doc->vScroll) 
		gCurrentScrollAmount = METHOD_GetVertLineScrollAmount(doc);
	else if (theControl == doc->hScroll) 
		gCurrentScrollAmount = METHOD_GetHorizLineScrollAmount(doc);
	TrackControl(theControl,localPt, myControlActionUPP);  /*BH: removed ProcPtr*/
}


static void DoThumbScroll(DocumentPtr doc, ControlHandle theControl,Point localPt)
{
	short oldValue,trackResult,newValue,diff;
	
	oldValue = GetControlValue(theControl);
	trackResult = TrackControl(theControl,localPt,NULL);
	if(trackResult == kControlIndicatorPart) {
		newValue = GetControlValue(theControl);
		diff = oldValue - newValue;
		METHOD_FocusOnContent(doc);
		if(theControl== doc->hScroll)
			METHOD_ScrollContents(doc,diff,0);
		if(theControl== doc->vScroll)
			METHOD_ScrollContents(doc,0,diff);
		METHOD_FocusOnDocument(doc);
	}
}


void DoPageScroll(DocumentPtr doc, ControlHandle theControl,short part)
{
	short scrollAmount;
	Point thePt;
	short currentPart;
	long repeatTicks;	/*BH: delay for repeat inserted */
		
	if(theControl == doc->vScroll)
		scrollAmount=METHOD_GetVertPageScrollAmount(doc);
	else
		scrollAmount=METHOD_GetHorizPageScrollAmount(doc);
		
	/* repeat as long as user holds down mouse button */
	repeatTicks = TickCount() + GetDblTime();
	do {  
		GetMouse(&thePt);
		if(part<0) 
			currentPart=part=-part;
		else /* BH: changed part names to new standard */
			currentPart = TestControl(theControl,thePt);
		if(currentPart == part) {
			if(currentPart == kControlPageUpPart)
				Scroll(doc, theControl,-scrollAmount);
			if(currentPart == kControlPageDownPart)
				Scroll(doc, theControl,scrollAmount);
		}
		while (TickCount() < repeatTicks)   /* BH: inserted to make scroll bars less 'nervous' */
			if (!StillDown())
				return;
	} while (StillDown());
}



pascal void myControlActionProc(ControlHandle theControl,short partCode)
{
	if(partCode == kControlUpButtonPart)	
		Scroll(gCurrentDocument, theControl,-gCurrentScrollAmount);
	else if(partCode == kControlDownButtonPart)	
		Scroll(gCurrentDocument, theControl,gCurrentScrollAmount);
}


pascal Boolean myClicker(void)
{
	Rect		viewRect;
	Point		mousePoint;
	RgnHandle	saveClip;
	long		lineHeight, width, hDelta,vDelta;
	TE32KHandle tH;
	
	if (gCurrentDocument && (tH = gCurrentDocument->docData)) {
		LongRectToRect(&((**tH).viewRect),&viewRect);
		lineHeight = (**tH).lineHeight;
		width = (**tH).theCharWidths[' '];
		
		hDelta = 0L;
		vDelta = 0L;
		
		GetMouse(&mousePoint);
		
		if (!PtInRect(mousePoint,&viewRect)) {
			if (mousePoint.v > viewRect.bottom && 
					(vDelta = (**tH).viewRect.bottom - (**tH).destRect.top - lineHeight * (**tH).nLines) < 0 ) {
				if (vDelta < -lineHeight)
					vDelta = -lineHeight;
			
			} else if (mousePoint.v < viewRect.top 
					&& (vDelta = (**tH).viewRect.top - (**tH).destRect.top) > 0) {
				if (vDelta > lineHeight)
					vDelta = lineHeight;
			}
			
			if (mousePoint.h > viewRect.right && (hDelta = (**tH).viewRect.right - (**tH).destRect.right) < 0) {
				if (hDelta < -width)
					hDelta = - width;
			
			} else if (mousePoint.h<viewRect.left && (hDelta = (**tH).viewRect.left - (**tH).destRect.left) > 0) {
				if (hDelta > width)
					hDelta = width;
			}
		}
		
		if (hDelta || vDelta) {
			saveClip = NewRgn();
			GetClip(saveClip);
			GetWindowPortBounds (gCurrentDocument->docWindow, &viewRect);
			ClipRect(&viewRect);
			
			TE32KScroll(hDelta,vDelta,tH);
			METHOD_AdjustScrollBars(gCurrentDocument);
			SetClip(saveClip);
			DisposeRgn(saveClip);
		}
	}
	return true;
}



/****************************************************************************
**
**  Methods for editable text windows
*/
Boolean textDestructor (DocumentPtr doc)
{
	TE32KHandle tH;
	if((tH = doc->docData)) {
		TE32KDispose(tH);
		doc->docData=0;
	}
	if(doc->fPrintRecord)
		DisposeHandle ((Handle) doc->fPrintRecord);
	return defaultDestructor(doc);
}


void textScrollContents (DocumentPtr doc,short dh,short dv) 
{
	TE32KHandle tH;
	
	if(tH = doc->docData)
		TE32KScroll((long)dh,(long)dv*(**tH).lineHeight,tH);
}

short textGetVertLineScrollAmount (DocumentPtr doc)
{
	if(doc->docData)
		return 1;
	else
		return 0;
}

short textGetHorizLineScrollAmount (DocumentPtr doc)
{
	if (doc->docData)
		return (**(doc->docData)).theCharWidths['M'];
	else 
		return 0;
}

void textGetContentRect (DocumentPtr doc,Rect *r)
{
	defaultGetContentRect(doc,r);
	r->left += 4;
	r->top	+= 4;
	r->bottom -= 2;
	r->right -= 2;
}

short textGetVertSize (DocumentPtr doc)
{
	if (doc->docData)
		return((**(doc->docData)).nLines);
	else 
		return 0;
}

short textGetHorizSize (DocumentPtr doc)
{
	TE32KHandle tH;
	
	if ((tH = doc->docData)) 
		return (**tH).destRect.right - (**tH).destRect.left;
	else
		return 0;
	/* 	Note that the destRect is the same as the viewRect when word
		wrapping to window. */
}

void textDoPageSetup (DocumentPtr doc)
{
	PrOpen();
	PrStlDialog( doc->fPrintRecord);
	PrClose();
}


#if 0
void textPrintDraw (DocumentPtr doc,Rect *r,short)
{
	TE32KHandle tH;
	short i,firstLine,lastLine;
	
	tH = doc->docData;
	TextFont((**tH).txFont);
	TextSize((**tH).txSize);
	firstLine=r->top;
	lastLine=r->bottom;
	
	HLock((**tH).hText);
	for(i=firstLine;i<lastLine;i++) {
		MoveTo(LeftMargin,(**tH).lineHeight*(i-firstLine)+TopMargin+(**tH).fontAscent);
		DrawText(*(**tH).hText+(**tH).lineStarts[i],0,(**tH).lineStarts[i+1]-(**tH).lineStarts[i]);
	}
	HUnlock((**tH).hText);
}

#else

void textPrintDraw (DocumentPtr doc,Rect *r,short page)
{
	long i,firstChar,lastChar;
	short firstLine,lastLine,vPos;
	long tabWidth;
	short pageWidth;
	unsigned char *textPtr;
	GrafPtr currentPort;
	TE32KHandle tH;
	Str31 numStr;
	Point pnLoc;
	
	tH = doc->docData;
	
	GetPort(&currentPort);
	
	TextFont((**tH).txFont);
	TextFace((**tH).txFace);
	TextSize((**tH).txSize);
	TextMode((**tH).txMode);
				
	firstLine=r->top;		/* zero indexed */
	lastLine=r->bottom;
	
	HLock((**tH).hText);
	textPtr = (unsigned char *) *((**tH).hText);
	tabWidth = (long)(**tH).tabWidth;
	
	vPos = TopMargin;
	
	while(firstLine<lastLine) {
		i=firstChar = (**tH).lineStarts[firstLine];
		lastChar = (**tH).lineStarts[firstLine+1];
		if (lastChar > firstChar && ISEOL(textPtr[lastChar-1]))
			lastChar--;
		MoveTo(LeftMargin,vPos);
		if((**tH).showInvisibles) {
			while (firstChar < lastChar) {
				while (i<lastChar && textPtr[i]>=0x20 && !isspace(textPtr[i]))
					i++;

				if (i > firstChar)
					DrawText(&(textPtr[firstChar]),0,(short) (i - firstChar));
				
				if(i<lastChar) {
					if (textPtr[i]==TAB) {
						DrawChar('');
						GetPortPenLocation (currentPort, &pnLoc);
						MoveTo(LeftMargin + ((pnLoc.h - LeftMargin + tabWidth)/tabWidth)*tabWidth, pnLoc.v);
					} else if(textPtr[i]==' ')
						DrawChar('×');
					else if(textPtr[i]=='\n')
						DrawChar('¬');
					else 
						DrawChar('¿');
					i++;
				}
				
				firstChar = i;
				
			}
			if(i<(**tH).teLength && textPtr[i]=='\n')
				DrawChar('¬');
		} else {
			while (firstChar < lastChar) {
				while (i<lastChar && textPtr[i]!=TAB)
					i++;
				
				if (i > firstChar)
					DrawText(&(textPtr[firstChar]),0,(short) (i - firstChar));
				
				if (i<lastChar && textPtr[i]==TAB) {						
					GetPortPenLocation (currentPort, &pnLoc);
					MoveTo(LeftMargin + ((pnLoc.h - LeftMargin + tabWidth)/tabWidth)*tabWidth, pnLoc.v);
					i++;
				}
				
				firstChar = i;
				
			}
		}
		vPos += (**tH).lineHeight;
		firstLine++;
	}
	pageWidth=(** doc->fPrintRecord).prInfo.rPage.right;
	NumToString(page,numStr);
	pageWidth -= StringWidth(numStr);
	MoveTo(pageWidth/2,(** doc->fPrintRecord).prInfo.rPage.bottom);
	DrawString(numStr);

	HUnlock((**tH).hText);
}
#endif

void textDraw (DocumentPtr doc, Rect *r, short page)
{
	RgnHandle rgn, rgn2;
	Rect viewRect;
	LongRect lr;
	
	TE32KHandle tH;
	if( tH = doc->docData) {
		if(page) 							/* Printing method */
			textPrintDraw(doc,r,page);
		else {
			LongRectToRect (&(**tH).viewRect, &viewRect);
			defaultFocusOnDocument (doc);
			/* erase everything outside the text part */
			rgn = NewRgn ();
			rgn2 = NewRgn ();
			RectRgn (rgn, r);
			RectRgn (rgn2, &viewRect);
			DiffRgn (rgn, rgn2, rgn);
			DisposeRgn (rgn2);
			EraseRgn (rgn);
			DisposeRgn (rgn);
			/* draw the text part */
			RectToLongRect (r, &lr);
			TE32KUpdate(&lr, tH);
		}
	}
}
#if TARGET_API_MAC_CARBON
void textDoPrint (DocumentPtr doc)
{
	SysBeep(3);
}
#else
void textDoPrint (DocumentPtr doc)
{
	TPPrPort printPort;
	TPrStatus status;
	TE32KHandle tH;
	OSErr err;
	short page,nPages;
	Rect r;
	short pageHeight,linesPerPage;
	short firstLine,lastLine;
	long memavail;
	
	if (!gPrintBufferSize) 
		return;
	memavail = MaxBlock ();
	if (memavail < gPrintBufferSize) {
		UnloadScrap ();
		memavail = MaxBlock ();
	}
#ifdef GAPVER
	if (memavail < gPrintBufferSize && (tH = LOGDOCUMENT.docData)) {
		if (!doConfirmDialog (9,"\p"))
			return;
		TruncateDocument (&LOGDOCUMENT, gPrintBufferSize - memavail);
		if ((**tH).hText)
			SetHandleSize ((**tH).hText, (**tH).teLength);
		memavail = MaxBlock ();
		if (memavail < gPrintBufferSize) {
			TruncateDocument (&LOGDOCUMENT, 0);
			memavail = MaxBlock ();
		}
	}
#endif
	if (memavail < gPrintBufferSize)
		if (!doConfirmDialog (8,"\p"))
			return;
	
	METHOD_Deactivate (doc);
	PrOpen();
	if ((err=PrError ()) == noErr) {
		if(PrValidate( doc->fPrintRecord)) {
			if(!PrStlDialog( doc->fPrintRecord)) {
				PrClose ();
				return;
			} 
		}
		if(!PrJobDialog( doc->fPrintRecord)) {
			PrClose();
			return;
		}
		if ((err=PrError ()) == noErr) {
			printPort = PrOpenDoc( doc->fPrintRecord,NULL,NULL);
			tH = doc->docData;
			
			pageHeight =(** doc->fPrintRecord).prInfo.rPage.bottom;
			linesPerPage=(pageHeight-TopMargin-BottomMargin)/(**tH).lineHeight;
			nPages=1+(**tH).nLines/linesPerPage;
				
			for(page=1;page<=nPages && (err=PrError ()) == noErr;page++) {
				firstLine=(page-1)*linesPerPage;
				if(firstLine<0) 
					firstLine=0;
				lastLine=firstLine+linesPerPage;
				if(lastLine>(**tH).nLines)
					lastLine=(**tH).nLines;
				r.top=firstLine;
				r.bottom=lastLine;
				PrOpenPage(printPort,NULL);
				METHOD_Draw(doc,&r,page);
				PrClosePage(printPort);
			}
			PrCloseDoc(printPort);
			if((** doc->fPrintRecord).prJob.bJDocLoop != NULL) 
				PrPicFile( doc->fPrintRecord,NULL,NULL,NULL,&status);
		}
	}
	PrClose();
	if (err == noErr)
		err=PrError ();
	switch (err) {
		case iPrAbort:
			FlushEvents (keyDownMask, 0);
			break;
		case noErr:
			break;
		case memFullErr:
#ifndef GAPVER
			doMessage (2);
#endif
			break;
		default:
			doDiagnosticMessage (13, err);
			break;
	}
	METHOD_Activate (doc);
}
#endif

void textActivate (DocumentPtr doc)
{
	defaultAactivate(doc);
	if( doc->docData)
		TE32KActivate(doc->docData);
}

void textDeactivate (DocumentPtr doc)
{
	defaultDeactivate(doc);
	if( doc->docData)
		TE32KDeactivate(doc->docData);
}

void textDoIdle (DocumentPtr doc)
{
	GrafPtr oldPort;
	Point pt;
	
#ifdef DEBUG_MARKS
	TE32KHandle tH;
	DocumentPtr doc;
	MarkRecPtr theMark;
	long offset;
	char *p,*q;

	doc = DOCUMENTPEEKFrontLayer();
	tH = doc->docData;
# if MARKS
	if(tH && doc->marks) {
		theMark = (MarkRecPtr)(*doc->marks+2);
		offset = theMark->selStart;
		p=*(**tH).hText+offset;
		q=&theMark->label;
		if(*p != q[1])
			SysBeep(7);
	}
# endif
#endif
	
	if( doc->docData) 
		TE32KIdle( doc->docData);
	GetPort(&oldPort);
	SetPortWindowPort (doc->docWindow);
	GetMouse(&pt);
	METHOD_AdjustCursor(doc,pt);
	SetPort(oldPort);
}

void textAdjustCursor (DocumentPtr doc,Point where)
{
	Rect r;
	CursHandle IBeam;
	
	METHOD_GetContentRect(doc,&r);
	if(PtInRect(where,&r)) {
		IBeam = GetCursor(iBeamCursor);
		if(IBeam)
			SetCursor(*IBeam);
	} else
		InitCursor();
}


Boolean textConvertKey (DocumentPtr doc,EventRecord *theEvent)
{
	return ConvertGAPKeys (doc, theEvent, false);
}




void textDoKeyDown (DocumentPtr doc,EventRecord *theEvent)
{
	Boolean result;
	unsigned char ch;
	TE32KHandle tH;
#if MARKS
	long selStart,selEnd,delta;
#endif
	if(tH = doc->docData) {
		ch=theEvent->message&charCodeMask;

#if MARKS
			/* 
				There is not need to update marks during normal typing as the undoStart and undoEnd
				range provide an adequate record of how the buffer (hText) has changed. Two case
				where updating are necessary are flagged here:
					1. When auto-indenting and spaces follow the cursor
					2. A selection range made by shift-arrow key combinations is deleted, after 
						some previous typing.
				Number 2 is too complex, so lets just update marks whenever a shifted character is 
				typed. This catches all shift-arrow combinations. Updating with every new sentence
				is not an important penalty.
			*/
			if(ch==RETURN && (**tH).autoIndent 
					&& doc->fNeedToUpdateMarks
					&& (*(*(**tH).hText + (**tH).selEnd)==' ' || *(*(**tH).hText + (**tH).selEnd)==TAB)) {  /*BH ptr == char replaced by *ptr == char (twice) */
				UpdateMarks(DOCUMENTPEEKwind,(**tH).undoStart,(**tH).undoEnd,(**tH).undoStart-(**tH).undoEnd,(**tH).teLength);
			} else if( doc->fNeedToUpdateMarks &&
				(ch==LEFTARROW || ch==RIGHTARROW || ch==UPARROW || ch==DOWNARROW)) {
				selStart = (**tH).undoStart;
				selEnd = (**tH).undoEnd;
				if(selEnd > selStart)
					delta = selEnd - selStart;
				else 
					delta=0;
				if((**tH).undoBuf)
					delta -= GetHandleSize((**tH).undoBuf);
				/*
					This is the second use of (**tH).undoDelta for input. The other is in 
					ContentClick, which is the other way of moving the insertion point.
				*/
				delta -= (**tH).undoDelta;
				(**tH).undoDelta = delta;
				if(selEnd > selStart)
					selEnd-=delta;
				UpdateMarks(DOCUMENTPEEKwind,selStart,selEnd,delta,(**tH).teLength);
			}
#endif				
			result = TE32KKey(ch,tH,theEvent->modifiers);
			
#if MARKS
			 doc->fNeedToUpdateMarks |= result;
#endif
			 doc->fNeedToSave |= result;
					
			/* SynchScrollBars */
			TE32KSelView(tH);
			METHOD_AdjustScrollBars(doc);
			doc->fHaveSelection = SetSelectionFlag(tH);
	}
}

void textReadOnlyDoKeyDown (DocumentPtr doc,EventRecord *theEvent)  /*BH: renamed "ReadOnly" */
{
	unsigned ch;
	TE32KHandle tH;
	
	if(tH = doc->docData) {
		ch=theEvent->message&charCodeMask;

		if(ch==LEFTARROW || ch==RIGHTARROW || ch==UPARROW || ch==DOWNARROW) {
			
			TE32KKey(ch,tH,theEvent->modifiers);

			/* SynchScrollBars */
			TE32KSelView(tH);
			METHOD_AdjustScrollBars(doc);
			 doc->fHaveSelection = SetSelectionFlag(tH);

		} else 
			SysBeep (4);  /* was: doMessage(18); */
	}
}


static void SetTE32KRect (DocumentPtr doc)
{
	Rect r;
	TE32KHandle tH;
	
	if( (tH = doc->docData)) {
		METHOD_GetContentRect(doc,&r);
		RectToLongRect(&r,&(**tH).viewRect);
		
		(**tH).viewRect.bottom -= ((**tH).viewRect.bottom - (**tH).viewRect.top) % (**tH).lineHeight;
		
		(**tH).destRect.top += ((**tH).viewRect.top - (**tH).destRect.top) % (**tH).lineHeight;
		
		if((**tH).crOnly)
			(**tH).destRect.right=(**tH).destRect.left+8192;
		else if((**tH).wrapToLength) {
			(**tH).destRect.right=(**tH).destRect.left+(**tH).maxLineWidth*(**tH).theCharWidths['M'];
		} else {
			(**tH).destRect.right=(**tH).viewRect.right;
			(**tH).destRect.left=(**tH).viewRect.left;
		}

		if (!(**tH).crOnly);
			TE32KCalText(tH);
				
		TE32KSetSelect((**tH).selStart,(**tH).selEnd,tH);
		TE32KSelView (tH);
		
		doc->fHaveSelection = SetSelectionFlag(tH);

		METHOD_AdjustScrollBars(doc);
	}
}


void textDoResize (DocumentPtr doc, Boolean moved)
{
	TE32KHandle tH;
	Rect oldView, newView;
	RgnHandle rgn, rgn2;
	
	if(doc && (tH = doc->docData)) {
		METHOD_FocusOnDocument (doc);			
		
		rgn = NewRgn ();
		GetWindowPortBounds (doc->docWindow, &oldView);
		RectRgn (rgn, &oldView);
		
		/* 	if left upper corner stayed in place, the window is not
			line wrapped, and does not need to be scrolled, 
			we can still use the part of the 
			contents rectangle which is in the new one */

		if (!moved  && (**tH).crOnly) { 
			LongRectToRect (&(**tH).viewRect, &oldView);
		}
				
		SetTE32KRect(doc);
		
		if (!moved  && (**tH).crOnly) {
			LongRectToRect (&(**tH).viewRect, &newView);
			SectRect (&newView, &oldView, &oldView);
			rgn2 = NewRgn ();
			RectRgn (rgn2, &oldView);
			DiffRgn (rgn, rgn2, rgn);
			DisposeRgn (rgn2);
		}
		
#if DEBUG_UPDATE
		FillRgn (rgn, &qd.gray);
#endif
		EraseRgn (rgn);
		InvalRgn (rgn);
		DisposeRgn (rgn);
		SizeScrollBars(doc);

		
		if (!doc->fNoGrow)
			DrawGrowIcon(doc->docWindow);
	}
}


void textDoContent (DocumentPtr doc,EventRecord *event)
{
	Rect contents;
	Boolean shiftKeyDown;
	TE32KHandle tH;
#if MARKS
	long selStart,selEnd,delta;
#endif
#ifdef GAPVER
	long selStart,selEnd;
	char buf[256], match;
	short clicks;
#endif
	
	METHOD_FocusOnDocument(doc);
	GlobalToLocal(&event->where);
	METHOD_GetContentRect(doc,&contents);
	if(PtInRect(event->where,&contents)) {
		shiftKeyDown =((event->modifiers & shiftKey) != 0);
		/*
			This is the first use of (**tH).undoDelta as input. UndoDelta
			keeps a record of previous UpdateMarks. Obviously, one can click 
			many times and there be no change in the undoBuffer and UpdateMarks 
			based on the undoBuffer values shouldn't be redone.
			
			The other use is for arrow key cursor movement.
		*/
		if(tH = doc->docData) {
#if MARKS
			if( doc->fNeedToUpdateMarks) {
				selStart = (**tH).undoStart;
				selEnd = (**tH).undoEnd;
				if(selEnd > selStart)
					delta = selEnd - selStart;
				else
					delta = 0;
				if((**tH).undoBuf)
					delta -= GetHandleSize((**tH).undoBuf);
				delta -= (**tH).undoDelta;
				(**tH).undoDelta = delta;
				if(selEnd > selStart)
					selEnd-=delta;
				UpdateMarks(DOCUMENTPEEKwind,selStart,selEnd,delta,(**tH).teLength);
			}
#endif
			gCurrentDocument = doc; /* for click callback routine */
			clicks = TE32KClick(event->where,shiftKeyDown,tH);
			METHOD_AdjustScrollBars(doc);
			doc->fHaveSelection = SetSelectionFlag(tH);
#ifdef GAPVER
			if (event->modifiers & cmdKey) {
				if (clicks && (selStart = (**tH).selStart) < (selEnd = (**tH).selEnd)) {
					if (selStart > 0 
							&& (match = islbracket((*(**tH).hText)[selStart-1]))) {
						while (selEnd <= (**tH).teLength && (*(**tH).hText)[selEnd] != match) {
							if (islbracket((*(**tH).hText)[selEnd]))
								goto noBracket; /* no matching right bracket found */
							selEnd++;
						}
						if (selEnd > (**tH).teLength) goto noBracket;
					}
					else if (selEnd < (**tH).teLength
							&& (match = isrbracket((*(**tH).hText)[selEnd]))) {
						while (--selStart > 0 && (*(**tH).hText)[selStart] != match)
							if (isrbracket ((*(**tH).hText)[selStart]))
								goto noBracket; /* no matching right bracket found */
						if (selStart < 0) goto noBracket;
						selStart++;
					}
					else 
						goto noBracket;
					TE32KSetSelect (selStart, selEnd, tH);
					doc->fHaveSelection = SetSelectionFlag(tH);
				}
noBracket:
				if (event->modifiers & optionKey && GetSelection (doc, buf+1, 254)) {
					buf[0] = '?';
					GET_GAP_HELP (buf); /*cmd-option-double-click */
				}
				else if (GetSelection (doc, buf, 255))   /*cmd-select */
					GET_GAP_HELP ((buf[0] == '?')?  buf+1 : buf);
			}
#endif		
		}
	} else
		ScrollClick(doc,event);
}

void RectLocalToGlobal(Rect *r)
{
	Point pt;
	
	pt.h=r->left;
	pt.v=r->top;
	LocalToGlobal(&pt);
	r->left=pt.h;
	r->top=pt.v;

	pt.h=r->right;
	pt.v=r->bottom;
	LocalToGlobal(&pt);
	r->right=pt.h;
	r->bottom=pt.v;
}

void RectGlobalToLocal(Rect *r)
{
	Point pt;
	
	pt.h=r->left;
	pt.v=r->top;
	GlobalToLocal(&pt);
	r->left=pt.h;
	r->top=pt.v;

	pt.h=r->right;
	pt.v=r->bottom;
	GlobalToLocal(&pt);
	r->right=pt.h;
	r->bottom=pt.v;
}

#if 0 /* BH: don't seem to need this */
Boolean inStdState (DocumentPtr doc,Rect *r)
{
	Handle h;
	WStateData *ws;
	Boolean ret;
	GrafPtr oldPort;
	
	if(!((WindowPeek)(doc->docWindow))->spareFlag)
		return false;
	h=((WindowPeek)(doc->docWindow))->dataHandle;
	if(!h)
		return false;
	HLock(h);
	ws = (WStateData *)(*h);
	GetWindowPortBounds (doc->docWindow, r);
	GetPort(&oldPort);
	SetPortWindowPort (doc->docWindow);
	RectLocalToGlobal(r);
	SetPort(oldPort);
	ret=EqualRect(r,&ws->stdState);
	HUnlock(h);
	return ret;
}
#endif 

Boolean textInitDoc (DocumentPtr doc)
{
#if MARKS
	Handle mH;
	OSErr err;
#endif

	LongRect view, dest;
	TE32KHandle tH;
	Rect r;
	GDHandle mainGD;
	short n;
	
	n = CountDocuments ();
	SetRect(&r,	gDefaultDocRect.left + 10 * n,   /*BH: now usess gDefaultDocRect; use same values as StackWindows () */
				gDefaultDocRect.top + 20 * n,
				gDefaultDocRect.right + 10 * n,
				gDefaultDocRect.bottom + 20 * n);
	mainGD=GetMainDevice();
	SectRect (&(**mainGD).gdRect, &r, &r);

	if(!((r.right-r.left)%2)) r.right--;
	if(!((r.bottom-r.top)%2)) r.bottom--;


	doc->docWindow = NewWindow(doc->docWindow, &r, doc->fileSpecs.name, 
		false, zoomDocProc, (WindowPtr)-1, true, NULL); 

	if (!doc->docWindow)
		return false;
	
	SetRect(&doc->limitRect,100,100,kMaxShort,kMaxShort);
	
	if(!(doc->fPrintRecord = (THPrint)NEWHANDLE(sizeof(TPrint))) || MEMERROR ())
		return false;
	PrOpen();
	PrintDefault(doc->fPrintRecord);
	PrClose();

	SetPortWindowPort (doc->docWindow);
	TextFont(kFontIDMonaco); /* BH: replaced monaco by kFontIDMonaco */
	TextSize(9);
	GetWindowPortBounds (doc->docWindow, &r);
	RectToLongRect(&r,&dest);
	view=dest;
	dest.right=2000;
	dest.bottom=2000;
	dest.left+=4;
	dest.top+=4;
	tH=TE32KNew(&dest,&view);
	if(tH == NULL) {
		DisposeWindow(doc->docWindow);
		doc->docData=NULL;
		InitCursor();
		doMessage(5);	
		return false;
	}
	(**tH).crOnly = true;    
	(**tH).autoIndent = true;    
	doc->docData = tH;
	doc->fNeedToSave = false;

	if(!InitScrollDoc(doc))
		return false;
		
#if MARKS
	if (doc->resourcePathRefNum) {
		UseResFile (doc->resourcePathRefNum);
		mH=Get1Resource('MENU',MARK_ID);
		if (mH && ResError() == noErr) {
			if (HandToHand(&mH) == noErr)
				doc->markMenu=(MenuHandle)mH;
		}
	}
#endif

	SetTE32KRect(doc);

	(**tH).clikLoop = myClicker;
		
	DrawControls(doc->docWindow);
	DrawGrowIcon(doc->docWindow);
	doc->fValidDoc=true;

	return true;
}

#if MARKS || STATE
Boolean ReadTextDocResourceFork (DocumentPtr doc)
{
	Handle res;
	short err,refNum;
#if MARKS
	short nMarks;
#endif
	RgnHandle grayRgn;
	Point p;
	/*	
		Text files have two resources. Both follow formats used by MPW.
	
		MPSR 1005 is obligatory and encodes all format information, window
		size, scroll bar position and selection range.
		
		MPSR 1007 encodes marks.
	*/
	
	refNum=doc->resourcePathRefNum;
	if(!refNum)
		return false;
		
	UseResFile(refNum);

#if STATE
	res=Get1Resource('MPSR',1005);
	if ((err = ResError ()) != noErr)
		res = 0;

	if (res && GetHandleSize (res) != sizeof(MPSRWindowResource)) {
		doMessage (17);
		ReleaseResource (res);
	}
	doc->windowState=(MPSRWindowResource**)res;
	
	if (res) {
		/* make sure that upper left or upper right hand corners of window are visible and they have a 
		   certain minimum size */
		grayRgn = GetGrayRgn();
		
		p.v = (**(doc->windowState)).userState.top;
		p.h = (**(doc->windowState)).userState.left;
		
		if (!PtInRgn (p, grayRgn) && !PtInRgn (p, grayRgn)) {
#if TARGET_CPU_PPC
			GetWindowPortBounds (doc->docWindow, &(**(doc->windowState)).userState);
#else
			(**(doc->windowState)).userState = doc->docWindow->portRect;
#endif
			RectLocalToGlobal (&(**(doc->windowState)).userState);
		}

		if ((**(doc->windowState)).userState.bottom - (**(doc->windowState)).userState.top < 40)
			(**(doc->windowState)).userState.bottom = (**(doc->windowState)).userState.top + 40;
		if ((**(doc->windowState)).userState.right - (**(doc->windowState)).userState.left < 40)
			(**(doc->windowState)).userState.right = (**(doc->windowState)).userState.left + 40;

		p.v = (**(doc->windowState)).stdState.top;
		p.h = (**(doc->windowState)).stdState.left;
		
		if (!PtInRgn (p, grayRgn) && !PtInRgn (p, grayRgn)) 
			(**(doc->windowState)).stdState = (**(doc->windowState)).userState;

		if ((**(doc->windowState)).stdState.bottom - (**(doc->windowState)).stdState.top < 40)
			(**(doc->windowState)).stdState.bottom = (**(doc->windowState)).stdState.top + 40;
		if ((**(doc->windowState)).stdState.right - (**(doc->windowState)).stdState.left < 40)
			(**(doc->windowState)).stdState.right = (**(doc->windowState)).stdState.left + 40;
		
		(**(doc->windowState)).modifiedDate=GetModDate(&doc->fileSpecs);
	}
#endif

	/* Now see if there are already marks for this file. */
	
#if MARKS
	res=Get1Resource('MPSR',1007);
	doc->marks=(ResError()==noErr)? res:0;
	if(res=doc->marks) {
		nMarks = *((short *)*res);
		if(nMarks == 0)	{	/* 	There are no marks. This can only 
										happen if a foreign file, i.e. MPW,
										has opened this file and left an
										MPSR 1007 resource that should have
										been removed. */
			RmveResource(res);
			err=ResError();
			DisposeHandle(res);
			doc->marks=0;
		}
	}
#endif	
	return true;
}
#endif


Boolean textOpenDocFile (DocumentPtr doc)
{
	if(defaultOpenDocFile(doc)) {

		AddTextDocumentMethods (doc);

		if(doc->fReadOnly) 
			AddTextReadOnlyMethods (doc);

		AdjustMenus (doc, 0);

		return true;
	}
	return false;
}


Boolean textReadDocFile (DocumentPtr doc)
{
	short refNum;
#if STATE
	short fontNum;
	long selEnd,selStart;
#endif
	long len, read;
	OSErr err;
	Handle theText;
	TE32KHandle tH;	
	Str255 numStr;
	
	if((doc->fValidDoc)&&(doc->docData)) {
		refNum=doc->dataPathRefNum;
		err = GetEOF(refNum,&len);

		theText=NEWHANDLE(len);
		if(MEMERROR() || theText==NULL) {
			doMessage(1);
			return false;
		}
		
		HLock(theText);
		err = SetFPos(refNum,fsFromStart,0);
		if (err == noErr) {
			read = len;
			err = FSRead(refNum,&read,(Ptr)*theText);
		}
		HUnlock(theText);
		
		if(err == noErr && len == read) {
			tH = doc->docData;
			TE32KUseTextHandle (theText, tH);	
			(**tH).undoStart=(**tH).undoEnd=0;  /* BH: clear undo buffer */
			if((**tH).undoBuf)
				DisposeHandle((**tH).undoBuf);
			TE32KSetEOF (tH);
#if STATE || MARKS
			ReadTextDocResourceFork(doc);
#endif

#if STATE						
			if(doc->windowState) {
				HLock((Handle)doc->windowState);
				(**tH).showInvisibles=(*doc->windowState)->showInvisibles;
				(**tH).crOnly = !((*doc->windowState)->wordWrap&2);
				(**tH).wrapToLength = (*doc->windowState)->wordWrap&4;
				(**tH).autoIndent = (*doc->windowState)->wordWrap&1;
				(**tH).tabChars=(*doc->windowState)->tabWidth;
				c2pstrcpy (numStr, (*doc->windowState)->fontName);
				GetFNum (numStr, &fontNum);
				TE32KSetFontStuff(fontNum,(**tH).txFace,(**tH).txMode,(*doc->windowState)->fontSize,tH);
				HUnlock((Handle)doc->windowState);

				selStart=(*doc->windowState)->vScrollValue;
				selEnd=indexToLine(selStart,tH);
				METHOD_ScrollContents(doc,(short)0,(short)-selEnd);
				
				selStart=(*doc->windowState)->selStart;
				selEnd=(*doc->windowState)->selEnd;
				if(selEnd>selStart)
					doc->fHaveSelection=true;
				TE32KSetSelect(selStart,selEnd,tH);
			} else
				TE32KSetSelect(0, 0, tH);
#else				
			TE32KSetSelect(0, 0, tH);
#endif

			METHOD_AdjustScrollBars(doc);
			
			return true;
		} else {
			doDiagnosticMessage (16, err == noErr? afpEofError:err);
			DisposeHandle(theText);
			return false;
		}
	}
	return false;
}

#if MARKS || STATE
Boolean textWriteDocResourceFork (DocumentPtr doc)
{
	short val;
#if MARKS
	short nMarks;
#endif
	Handle h,res;
	Rect r;
	WStateData *ws;
	MPSRPtr state;
	TE32KHandle tH;
	Str255 fontName;
	OSErr err;
	
	if(!doc->resourcePathRefNum)
		return false;
		
	UseResFile(doc->resourcePathRefNum);
	
#if STATE
	res=(Handle)doc->windowState;
	if(!doc->windowState) {
		/* Resource is missing. Make one. */
		res=NEWHANDLE(sizeof(MPSRWindowResource));
		if(!res || MEMERROR())
			return false;	/* Not enough memory */
		HLock(res);
		state=(MPSRPtr)*res;
		state->modifiedDate = GetModDate(&doc->fileSpecs);
	} else {
		HLock(res);
		state=(MPSRPtr)*res;
	}
	
	GetWindowUserState (doc->docWindow, &state->userState);
	GetWindowStandardState (doc->docWindow, &state->stdState);
	
	tH= doc->docData;
	state->selStart=(**tH).selStart;
	state->selEnd=(**tH).selEnd;
	val=GetControlValue(doc->vScroll);
	state->vScrollValue = (**tH).lineStarts[val];

	state->showInvisibles=(**tH).showInvisibles;
	state->wordWrap=(((**tH).autoIndent)?1:0) | (((**tH).crOnly)?0:2) |(((**tH).wrapToLength)?4:0);
	state->tabWidth=(**tH).tabChars;
	state->fontWidth=(**tH).theCharWidths[' '];
	state->fontSize=(**tH).txSize;
	
	GetFontName((**tH).txFont,fontName);

	BlockMove (fontName+1, state->fontName, fontName[0]);
	state->fontName[fontName[0]] = '\0';
	HUnlock(res);
		
	if(!doc->windowState) {
		doc->windowState=(MPSRWindowResource**)res;
		AddResource(res,'MPSR',1005,"\p");  /*BH: changed "" to "\p" */
	} else
		ChangedResource((Handle)doc->windowState);
	if ((err = ResError ()) == noErr)
		WriteResource((Handle)doc->windowState);
#endif

#if MARKS
	if(doc->marks) {
		nMarks = *(short *)*doc->marks ;
		if(nMarks) {
			if(HomeResFile(doc->marks)!=-1) {
				ChangedResource(doc->marks);
				WriteResource(doc->marks);
			} else  {
				AddResource(doc->marks,'MPSR',1007,"\p");   /*BH: changed "" to "\p" */
				WriteResource(doc->marks);
			}
		} else {
			if(res) {
				RmveResource(res);
				DisposeHandle(res);
			}
		}
	}		
#endif
	return true;
}
#endif

Boolean textWriteDocFile (DocumentPtr doc)
{
	short refNum;
	OSErr err;
	long len;
	Handle theText;
	TE32KHandle tH;
#if STATE
	unsigned long modDate;
#endif
		
	if((doc->fValidDoc)&&(doc->docData)) {
#if STATE || MARKS
		textWriteDocResourceFork(doc);
#endif
		refNum=doc->dataPathRefNum;
		tH = doc->docData;
		len = (**tH).teLength;
		theText = (**tH).hText;
		HLock(theText);
		err = SetFPos(refNum,fsFromStart,0);
		err |= FSWrite(refNum,&len,*theText);
		HUnlock(theText);
		err |= SetEOF(refNum,len);
		err |= FlushVol(0 ,doc->fileSpecs.vRefNum);   /*BH: changed "" to 0*/
		if(err==noErr) {
#if STATE
			if(doc->windowState) {
				GetDateTime(&modDate);
				(*doc->windowState)->modifiedDate = modDate;
			}
#endif
			return true;
		}
	}
	return false;
}

Boolean textReadIntoGAP  (DocumentPtr doc, Boolean all, Boolean reread)
{
#pragma unused(all)

	TE32KHandle tH;
	char buffer [1024];
	OSErr err;
	
	
	if (!(tH = doc->docData))
		return false;
		
	if (TE32KIsEOF (tH)) { /* prepare doc for reading */
		if (!doc-> fValidFSSpec)
			if (!DoSaveAs (doc)) 
				return false;  /* must save before read can take place */

		/* now doc contains a valid file spec, which we can pass on to GAP */		
		buffer[0] = '\0';
		if (reread) 
			SyStrncat ((char*)buffer, "Reread(\"", 8);
		else
			SyStrncat ((char*)buffer, "Read(\"", 6);
		err = FSSpecToPath (&doc->fileSpecs, buffer + SyStrlen (buffer), sizeof (buffer)-10, 
			true, false);
		if (err == noErr) {
			SyStrncat (buffer, "\");\n", 4);
			ExecuteGAPCommand (buffer);
		} else {
			doDiagnosticMessage (21, err);
			/* event has been handled, even if w/o success */
		}
	} else
		TE32KSetEOF (tH); /* handle 'abort read' */
	return true;
}
			

void textAdjustDocMenus (DocumentPtr doc, short modifiers)
{
	TE32KHandle tH;
#if MARKS
	long selStart,selEnd,delta=0;
#endif

	tH = doc->docData;
	
#if MARKS
	if(doc->fNeedToUpdateMarks &&tH) {
		selStart = (**tH).undoStart;
		selEnd = (**tH).undoEnd;
		if(selEnd > selStart)
			delta = selEnd - selStart;
		if((**tH).undoBuf) 
			delta -= GetHandleSize((**tH).undoBuf);
		delta -= (**tH).undoDelta;
		(**tH).undoDelta = delta;
		if(selEnd > selStart)
			selEnd-=delta;
		UpdateMarks( doc,selStart,selEnd,delta,(**tH).teLength);
	}
#endif
	
	/* File Menu */
	SETMENUABILITY(FileMenu,iClose,(GetWindowKind(doc->docWindow)!=13)
		&& TE32KIsEOF (tH)); /* if file is not already being read */
	SETMENUABILITY(FileMenu,iSave,doc->fNeedToSave);
	SETMENUABILITY(FileMenu,iSaveAs, GetWindowKind(doc->docWindow)!=13);
	EnableItem(FileMenu,iSaveACopy);
	SETMENUABILITY(FileMenu,iRevert,doc->fNeedToSave);
	SETMENUABILITY(FileMenu,iPageSetup, gPrintBufferSize);
	SETMENUABILITY(FileMenu,iPrint, gPrintBufferSize);

	SetMenuItemText (FileMenu, iClose, "\pClose");
	/* "Read" changes to "Save and Read" if the file hasn't a name, and to "Abort Read"
	if the file is being read */
	if (TE32KIsEOF (tH)) {
		SetMenuItemText (FileMenu, iRead, doc->fValidFSSpec?
		   (modifiers&shiftKey?"\pReread":"\pRead"):"\pSave & Read");
		SETMENUABILITY (FileMenu, iRead, gGAPIsIdle && tH);
		SetItemCmd (FileMenu, iRead, 'R');
	} else {
		SetMenuItemText (FileMenu, iRead, "\pAbort Read");
		SetItemCmd (FileMenu, iRead, '\0');
		EnableItem (FileMenu, iRead);
	} 
	DisableItem(FileMenu,iLogTo);
	/* Edit Menu */
	SETMENUABILITY(EditMenu,iUndo, tH && ((**tH).undoBuf) || (**tH).undoStart < (**tH).undoEnd);
	SETMENUABILITY(EditMenu,iCut, doc->fHaveSelection);
	SETMENUABILITY(EditMenu,iCopy, doc->fHaveSelection);
	EnableItem(EditMenu,iPaste);	
	SETMENUABILITY(EditMenu,iClear, doc->fHaveSelection);
	EnableItem(EditMenu,iSelectAll);

	EnableItem(EditMenu,iAutoIndent);
	CheckMenuItem (EditMenu, iAutoIndent, (**tH).autoIndent);
	EnableItem(EditMenu,iWrap);
	CheckMenuItem (EditMenu, iWrap, !(**tH).crOnly);
	EnableItem(EditMenu,iFormat);
	
	EnableItem(EditMenu,iAlign);
	EnableItem(EditMenu,iShiftRight);
	EnableItem(EditMenu,iShiftLeft);

	/* Find Menu */
	EnableItem(FindMenu,iFind);
	SETMENUABILITY(FindMenu,iFindSame,*gFindBuffer);
	SETMENUABILITY(FindMenu,iFindSelection, doc->fHaveSelection);
	EnableItem(FindMenu,iDisplaySelection);	
	EnableItem(FindMenu,iReplace);
	SETMENUABILITY(FindMenu,iReplaceSame,*gFindBuffer);
	EnableItem (FindMenu, iFindLine);
	
	EnableItem(FileMenu,0);
	EnableItem(EditMenu,0);
	EnableItem(FindMenu,0);
#if MARKS
	EnableItem(MarkMenu,0);
#endif
	EnableItem(WindowMenu,0);
#ifdef GAPVER
	if (HelpMenu)
		EnableItem (HelpMenu, 0);	
#endif
}


char *GetSelection (DocumentPtr doc,char *buf,long len)
{
	/* Returns a c string. */
	TE32KHandle tH;
	long selLen;
	
	*buf=0;
	if((tH= doc->docData) && (**tH).selStart<(**tH).selEnd) {
		selLen = (**tH).selEnd-(**tH).selStart;
		HLock((**tH).hText);
		selLen=(selLen<len)?selLen:len;
		BlockMove(*(**tH).hText+(**tH).selStart, buf, selLen);
		HUnlock((**tH).hText);
		*(buf+selLen)=0;
		return buf;
	}
	return 0;
}

#if MARKS
void textSelectMark (DocumentPtr doc,short item)
{
	TE32KHandle tH;
	short *mark;
	short i;
	
	if(tH= doc->docData) {
		HLock(doc->marks);
		mark = (short *)*doc->marks;
		for(mark++,i=1;i<item;i++)
			mark+= 4+(((MarkRecPtr)mark)->label+1)/2;
		TE32KSetSelect(((MarkRecPtr)mark)->selStart,((MarkRecPtr)mark)->selEnd,tH);
		HUnlock(doc->marks);
		positionView(tH,1);			
		METHOD_AdjustScrollBars(doc);
		doc->fHaveSelection = 1;		
	}
}
#endif

#if MARKS
void textNewMark (DocumentPtr doc)
{
	TE32KHandle tH;
	long selStart,selEnd;
	Str255 selection;
	
	if(tH= doc->docData) {
		selStart=(**tH).selStart;
		selEnd=(**tH).selEnd;
		GetSelection(doc,(char *) selection,63);
		InsertMark( doc,selStart,selEnd,(char *) selection);
	}
}
#endif

#if MARKS
void textUnMark(DocumentPtr doc)
{	
	TE32KHandle tH;
	long selStart,selEnd;
	
	if(doc->marks && (tH= doc->docData)) {
		selStart=(**tH).selStart;
		selEnd=(**tH).selEnd;
		DoUnmark(doc,selStart,selEnd);
	}
}
#endif


Boolean textDoDocMenuCommand (DocumentPtr doc, short menuID, short menuItem, short modifiers)
{
	short dialogItem;
	TE32KHandle tH;
	long line, start, end, len;
	Boolean back, wrap;
	Handle undoH;
	CursHandle watchHandle;
	Rect box;
	
	if(defaultDoDocMenuCommand(doc,menuID,menuItem,0))
		return true;
		
	tH = doc->docData;
	if (!tH) {
		SysBeep (4);
		return true;
	}
	
	switch(menuID) {
		case EDIT_ID:
			switch(menuItem) {
				case iFormat: 
					doFormatDialog(doc);
					break;
				case iWrap: 
					(**tH).crOnly = !(**tH).crOnly;
					TE32KCalText (tH);
					TE32KSetSelect ((**tH).selStart, (**tH).selEnd, tH);
					TE32KSelView (tH);
					METHOD_GetContentRect(doc,&box);
					SetPortWindowPort (doc->docWindow);
					InvalRect(&box);
					EraseRect(&box);
					break;
				case iAutoIndent: 
					(**tH).autoIndent = !(**tH).autoIndent;
					break;
				case iAlign:
					EnTabAndShift(doc,0);
					break;
				case iShiftRight:
					EnTabAndShift(doc,1);
					break;
				case iShiftLeft:
					EnTabAndShift(doc,-1);
					break;
			}
			break;
		case FIND_ID:
			switch(menuItem) {
				case iFind:
					if(doFindDialog(138)) {
						findSearchString(doc,modifiers&shiftKey);
						TE32KSelView(tH);			
						METHOD_AdjustScrollBars(doc);
					}
					break;
				case iFindSame:
					findSearchString(doc,modifiers&shiftKey);
					TE32KSelView(tH);			
					METHOD_AdjustScrollBars(doc);
					break;
				case iFindSelection:
					GetSelection(doc,(char *) gFindBuffer,255);
					c2pstr((char *) gFindBuffer);
					if(gSearchMethod==2)
						gSearchMethod=0;
					findSearchString(doc,modifiers&shiftKey);
					TE32KSelView(tH);			
					METHOD_AdjustScrollBars(doc);
					break;
				case iReplace:
					switch (dialogItem=doReplaceDialog()) {
						case 1:			/* Replace */
							if(findSearchString(doc,modifiers&shiftKey)) {
								TE32KDelete(tH);
								TE32KInsert((char *) gReplaceBuffer+1,(long)*gReplaceBuffer, tH); /* BH: (long)*gReplaceBuffer+1 is nonsense */
								doc->fNeedToSave=true;
							}
							break;
						case 7:			/* Replace All */
							back = gSearchBackwards;
							if (modifiers&shiftKey) 
								back = ! back;
							len = (**tH).teLength; /* need the previous length to compute end
								of undo area */
							if (back) {
								start = 0;
								end = gWrapSearch? len : (**tH).selStart;
							} else {
								start =  gWrapSearch?0: (**tH).selStart;
								end = len;
							}
							
							undoH=NEWHANDLE(end - start);
							if (MEMERROR() || undoH==NULL) {
								undoH = NULL;
								if (!doConfirmDialog(7, "\p"))
									return true;
							} else {
								HLock(undoH);
								HLock((**tH).hText);
								BlockMove(*((**tH).hText) + start, *undoH, end - start);
								HUnlock((**tH).hText);
								HUnlock(undoH);
							}
							
							watchHandle = GetCursor (watchCursor);
							if (watchHandle)
								SetCursor (*watchHandle);
								
							wrap = gWrapSearch; /* avoid infinite loop if replace string contains search string */
							gWrapSearch = false;
							
							while(findSearchString(doc,modifiers&shiftKey)) {
								TE32KDelete(tH);
								TE32KInsert((char *) gReplaceBuffer+1,(long)*gReplaceBuffer, tH); /* BH: (long)*gReplaceBuffer+1 is nonsense */
								if (back)
									TE32KSetSelect ((**tH).selStart - *gReplaceBuffer, 
										(**tH).selStart - *gReplaceBuffer, tH);
								doc->fNeedToSave=true;
							}
							gWrapSearch = wrap;
							
							InitCursor ();
							
							if((**tH).undoBuf)
								DisposeHandle((**tH).undoBuf);
								
							if (undoH) { /* if we could save the entire modified text */
								if (back) {
									(**tH).undoStart = 0;
									(**tH).undoEnd = gWrapSearch ? 
										(**tH).teLength : end + (**tH).teLength - len;
								} else {
									(**tH).undoStart =  gWrapSearch ? 0 : start;
									(**tH).undoEnd = (**tH).teLength;
								}
								(**tH).undoBuf = undoH;
								(**tH).resetUndo = true;
							} else { /* otherwise just clear the buffer */							
								(**tH).undoStart = (**tH).undoEnd = (**tH).selStart;
								(**tH).undoBuf=NULL;
								(**tH).resetUndo = false;
							}
#if MARKS
							(**tH).undoDelta = 0;
#endif
							break;
						case 8:			/* Find */
							findSearchString(doc,modifiers&shiftKey);
							break;
						default:
							break;
					}
					return true;
				case iReplaceSame:
					if(findSearchString(doc,modifiers&shiftKey)) {
						TE32KDelete( doc->docData);
						TE32KInsert((char *) gReplaceBuffer+1,(long)*gReplaceBuffer, doc->docData);
						doc->fNeedToSave=true;
						TE32KSelView(tH);			
						METHOD_AdjustScrollBars(doc);
					}
					return true;
				case iFindLine:
						tH = doc->docData;
						line = DoLineDialog((**tH).nLines, indexToLine ((**tH).selStart, tH)+1);
						if (line > 0) {
							TE32KSetSelect ((**tH).lineStarts[line-1], (**tH).lineStarts[line-1], tH);
							doc->fHaveSelection = 0;
							TE32KSelView(tH);			
							METHOD_AdjustScrollBars(doc);
						}
                        /* now display selection */
				case iDisplaySelection:
					positionView( doc->docData,1);
					METHOD_AdjustScrollBars(doc);
					break;
				default:
					break;
			}
			break;
#if MARKS
		case MARK_ID:
			if(menuItem==iMark) {	
				textNewMark(doc->docWindow);
			} else if(menuItem==iUnmark) {
				textUnMark(doc);
			} else if(menuItem==iAlphabetical) 
				return false;
			else 
				textSelectMark(doc,menuItem-4);
			return true;
#endif
		default:
			break;
	}
	return false;
}

short textGetVertPageScrollAmount (DocumentPtr doc)
{
	Rect r;
	short lineHeight;
	
	if (doc->docData) {
		lineHeight = (** doc->docData).lineHeight;
		METHOD_GetContentRect(doc,&r);
		return ((r.bottom - r.top)/lineHeight - 1);
	} else 
		return 0;
}
	
short textGetHorizPageScrollAmount (DocumentPtr doc)
{
	TE32KHandle tH;
	LongRect * viewRect;
	long res;
	
	if (tH = doc->docData) {
		viewRect = &(**tH).viewRect;
		res = viewRect->right - viewRect->left - (**tH).theCharWidths['M'];
		if (res > 0) {
			if (res < kMaxShort)
				return (short)res;
			else
				return kMaxShort;
		}
	} 
	return 0;
}

void textAdjustScrollBars (DocumentPtr doc)
{
	Rect visible;
	short lineHeight, hMax, vMax, dh = 0, dv = 0;
	TE32KHandle tH;
	LongRect dest;
	long hPos,vPos;
	
	METHOD_GetContentRect(doc,&visible);
	
	METHOD_FocusOnDocument(doc);

	if(tH = doc->docData) {
		dest = (**tH).destRect;
		lineHeight = (**tH).lineHeight;
		vPos = (visible.top - dest.top)/lineHeight;
		hPos = (visible.left - dest.left);  /*BH: divided by (**tH).charWidths[' '] ??? */
		vMax = METHOD_GetVertSize(doc) - 1; /* (visible.bottom-visible.top)/lineHeight; */
		if (vMax < 0)
			vMax = 0;
		hMax = METHOD_GetHorizSize(doc) - 1; /* (visible.right - visible.left); */
		if (hMax < 0)
			hMax = 0;

	}
	else 
		vPos = hPos = vMax = hMax = 0;

	if(doc->vScroll) {
		if(vPos>vMax) {
			dv = vPos - vMax;
			vPos = vMax;
		}
		SetControlMaximum(doc->vScroll,vMax);
		SetControlValue( doc->vScroll,(short)vPos);
	}

	if(doc->hScroll) {
		if(hPos > hMax) {
			dh = hPos - hMax;
			hPos = hMax;
		}
		SetControlMaximum(doc->hScroll,hMax);
		SetControlValue( doc->hScroll,(short)hPos);
	}	

	if(dh | dv) {
		METHOD_FocusOnContent(doc);
		METHOD_ScrollContents(doc,dh,dv);
	}
}

void textDoUndo (DocumentPtr doc)
{
#if MARKS
	long selStart,selEnd,delta=0;
#endif
	TE32KHandle tH;
	
	if (tH = doc->docData) {
#if MARKS
		selStart = (**tH).undoStart;
		selEnd = (**tH).undoEnd;
		if(selStart<selEnd) 
			delta=selStart-selEnd;
		if((**tH).undoBuf)
			delta+=GetHandleSize((**tH).undoBuf);
#endif
		TE32KUndo(tH);
#if MARKS
		UpdateMarks( doc,selStart,selEnd,delta,(**tH).teLength);
#endif
		doc->fHaveSelection = SetSelectionFlag(tH);
		METHOD_AdjustScrollBars(doc);
	}
}

void textDoCut (DocumentPtr doc)
{
	long selStart,selEnd;
	TE32KHandle tH;

	tH = doc->docData;
	selStart = (**tH).selStart;
	selEnd = (**tH).selEnd;
	TE32KCut(tH);
	doc->fNeedToSave=true;
#if MARKS
	UpdateMarks( doc,selStart,selEnd,selStart-selEnd,(**tH).teLength);
	(**tH).undoDelta = selStart-selEnd;
#endif
	METHOD_AdjustScrollBars(doc);
	if(gClipboardDoc) {
		tH=  gClipboardDoc->docData;
		TE32KSetSelect(0L,(**tH).teLength,tH);
		TE32KDelete(tH);
		TE32KPaste(  gClipboardDoc->docData);
		METHOD_AdjustScrollBars(gClipboardDoc);
	}
}

void textDoPaste (DocumentPtr doc)
{
#if MARKS
	long selStart,selEnd,delta;
#endif
	TE32KHandle tH;
	
	tH = doc->docData;
#if MARKS
	selStart = (**tH).selStart;
	selEnd = (**tH).selEnd;
#endif
	TE32KPaste(tH);
#if MARKS
	delta=selStart-selEnd;	/* -length of cut string */
	/* plus length of replacement string */
	delta+=TE32KScrpLength;
	UpdateMarks( doc,selStart,selEnd,delta,(**tH).teLength);
	(**tH).undoDelta=delta; 
#endif
	doc->fNeedToSave=true;
	doc->fHaveSelection = SetSelectionFlag(tH);
	TE32KSelView(tH);
	METHOD_AdjustScrollBars(doc);
}

void textDoClear (DocumentPtr doc)
{
	long selStart,selEnd;
	TE32KHandle tH;
	
	tH = doc->docData;
	selStart = (**tH).selStart;
	selEnd = (**tH).selEnd;
	TE32KDelete(tH);
	
	doc->fNeedToSave=true;
#if MARKS
	UpdateMarks( doc,selStart,selEnd,selStart-selEnd,(**tH).teLength);
#endif
	TE32KSelView(tH);
	METHOD_AdjustScrollBars(doc);
}

void textDoCopy (DocumentPtr doc)
{
	TE32KHandle tH;
	
	TE32KCopy( doc->docData);
	if(gClipboardDoc) {
		tH=  gClipboardDoc->docData;
		TE32KSetSelect(0L,(**tH).teLength,tH);
		TE32KDelete(tH);
		TE32KPaste(gClipboardDoc->docData);
#if 0  /* BH: is this reqlly required? */
		if((**tH).caretState)
			xorCaret(tH);
#endif
		METHOD_AdjustScrollBars(gClipboardDoc);
	}
}

void textSelectAll (DocumentPtr doc)
{
	TE32KHandle tH;
	if(tH= doc->docData) {
		TE32KSetSelect(0L,(**tH).teLength,tH);
		doc->fHaveSelection = SetSelectionFlag(tH);
	}
}

void AddTextDocumentMethods(DocumentPtr doc)
{
	AddDefaultDocumentMethods (doc);
	doc->mInitDoc=textInitDoc;
	doc->mDestructor=textDestructor;
	doc->mOpenDocFile=textOpenDocFile;
	doc->mReadIntoGAP=textReadIntoGAP; 
	doc->mReadDocFile=textReadDocFile;
	doc->mWriteDocFile=textWriteDocFile;
#if STATE || MARKS
	doc->mWriteDocResourceFork=textWriteDocResourceFork;
#endif
	doc->fDocType='TEXT';
	doc->mDraw=textDraw;
	doc->mDoPageSetup=textDoPageSetup;
	doc->mDoPrint=textDoPrint;
	doc->mActivate=textActivate;
	doc->mDeactivate=textDeactivate;
	doc->mDoContent=textDoContent;
	doc->mDoKeyDown=textDoKeyDown;
	doc->mConvertKey=textConvertKey;
	doc->mDoIdle=textDoIdle;
	doc->mDoResize=textDoResize;
	doc->mDoUndo=textDoUndo;
	doc->mDoCut=textDoCut;
	doc->mDoPaste=textDoPaste;
	doc->mDoClear=textDoClear;
	doc->mDoCopy=textDoCopy;
	doc->mDoSelectAll=textSelectAll;
	doc->mAdjustCursor=textAdjustCursor;
	doc->mAdjustScrollBars=textAdjustScrollBars;
#if 0
	doc->mSetScrollBarValues=textSetScrollBarValues;
#endif
	doc->mGetContentRect=textGetContentRect;
	doc->mGetHorizSize=textGetHorizSize;
	doc->mGetVertSize=textGetVertSize;
	doc->mGetVertPageScrollAmount=textGetVertPageScrollAmount;
	doc->mGetHorizPageScrollAmount=textGetHorizPageScrollAmount;	
	doc->mScrollContents=textScrollContents;
	doc->mGetVertLineScrollAmount=textGetVertLineScrollAmount;
	doc->mGetHorizLineScrollAmount=textGetHorizLineScrollAmount;
	doc->mAdjustDocMenus=textAdjustDocMenus;
	doc->mDoDocMenuCommand=textDoDocMenuCommand;
}


/****************************************************************************
**
**  special Methods for read-only text windows
*/
void textReadOnlyAdjustDocMenus (DocumentPtr doc, short modifiers)
{
	textAdjustDocMenus (doc, modifiers);
	
	/* File Menu */
	DisableItem(FileMenu,iSave);
	DisableItem(FileMenu,iRevert);
		
	/* Edit Menu */
	DisableItem(EditMenu,iUndo);
	DisableItem(EditMenu,iCut);
	DisableItem(EditMenu,iClear);
	
	DisableItem(EditMenu,iAlign);
	DisableItem(EditMenu,iShiftRight);
	DisableItem(EditMenu,iShiftLeft);
	
	DisableItem(FindMenu,iReplace);
	DisableItem(FindMenu,iReplaceSame);
}

void AddTextReadOnlyMethods(DocumentPtr doc)
{
	AddTextDocumentMethods (doc);
	doc->mDoCut=nullVoidDocumentMethod;
	doc->mDoPaste=nullVoidDocumentMethod;
	doc->mDoClear=nullVoidDocumentMethod;
	doc->mDoUndo=nullVoidDocumentMethod;
	doc->mDoKeyDown=textReadOnlyDoKeyDown;	
	doc->mWriteDocFile=nullBoolDocumentMethod; 
	doc->mAdjustDocMenus=textReadOnlyAdjustDocMenus;
}

/****************************************************************************
**
**  Format dialog for text windows
*/
static void UpdateSizeList (DialogPtr formatDialog,short fontNum,ListHandle *sizeList) 
{
	ListHandle theList=0;
	long textSize;
	short i,nRows,lastSize;
	short itemType;
	Handle itemHand;
	Point cellSize,cell;
	Rect box,dataBounds;
	Str255 data;
	
	if(*sizeList) 
		LDispose(*sizeList);
		
	GetDialogItem(formatDialog,9,&itemType,&itemHand,&box);
	GetDialogItemText(itemHand,data);
	StringToNum(data,&textSize);
	
	GetDialogItem(formatDialog,11,&itemType,&itemHand,&box);
	InsetRect(&box,1,1);
	EraseRect(&box);
	InvalRect(&box);

	cellSize.v=15;
	cellSize.h=box.right-box.left;

	box.bottom=box.top+cellSize.v*((box.bottom-box.top)/cellSize.v);
	box.right-=15;

	SetRect(&dataBounds,0,0,1,0);
	*sizeList=LNew(&box,&dataBounds,cellSize,0, GetDialogWindow (formatDialog),false,false,false,true);
	if(!*sizeList) {
		SysBeep(7);
		return;
	}
	
	cell.h=cell.v=0;
	nRows=0;
	i=(textSize<9)? textSize:9;
	for(;i<25;i++) {
		if(i==textSize || RealFont((short)fontNum,i)) {
			NumToString(i,data);
			LAddRow(1,nRows++,*sizeList);
			LSetCell(data+1,*data,cell,*sizeList);
			if(textSize==i) {
				LSetSelect(true,cell,*sizeList);
				LAutoScroll(*sizeList);
			}
			cell.v++;
		}
		if(i<8)
			i=8;
	}
	lastSize=i=(textSize>24 && textSize<30)? textSize:30;
	for(;i<97;i+=6) {
		if(i==textSize || RealFont((short)fontNum,i)) {
			NumToString(i,data);
			LAddRow(1,nRows++,*sizeList);
			LSetCell(data+1,*data,cell,*sizeList);
			if(textSize==i) {
				LSetSelect(true,cell,*sizeList);
				LAutoScroll(*sizeList);
			}
			cell.v++;
		} else if(textSize<i && textSize>lastSize) {
			NumToString(textSize,data);
			LAddRow(1,nRows++,*sizeList);
			LSetCell(data+1,*data,cell,*sizeList);
			LSetSelect(true,cell,*sizeList);
			LAutoScroll(*sizeList);
			cell.v++;
		}
	}
}

static ListHandle FillFontList (DialogPtr formatDialog,short fontNum,Point *fontCell)
{
	short i,nFonts;
	ListHandle theList=0;
	MenuHandle fMenu;
	Rect box,dataBounds;
	Point cellSize,cell;
	short itemType;
	Handle itemHand;
	Str255 fontName, font;
	
	if(fMenu=NewMenu(2202,"\p")) {    /*BH: changed "" to "\p" */
	
		/* Pending more study, the MenuManager's method for building a
			list of fonts, seems most efficient. Questions: are the font
			resources left in memory? Are they in alphabetical order? */
			
		AppendResMenu(fMenu,'FONT');
		nFonts = CountMItems(fMenu);
		
		GetDialogItem(formatDialog,10,&itemType,&itemHand,&box);
		InsetRect(&box,1,1);
	
		cellSize.v=15;
		cellSize.h=box.right-box.left;
	
		box.bottom=box.top+cellSize.v*((box.bottom-box.top)/cellSize.v);
		box.right-=15;
	
		SetRect(&dataBounds,0,0,1,nFonts);
		theList=LNew(&box,&dataBounds,cellSize,0, GetDialogWindow (formatDialog),false,false,false,true);

		if(!theList) {
			SysBeep(7);
			DisposeMenu(fMenu);
			return 0;
		}
		
		GetFontName(fontNum,fontName);
		cell.h=0;
		cell.v=0;
		HLock((Handle)fMenu);
		for(i=1;i<=nFonts;i++) {
			GetMenuItemText (fMenu, i, font);
			LSetCell(font+1,*font,cell,theList);
			if(EqualString (fontName,font, false, false)) {
				*fontCell=cell;
				LSetSelect(true,cell,theList);
				LAutoScroll(theList);
			}
			cell.v++;
		}
		HUnlock((Handle)fMenu);
		DisposeMenu(fMenu);
		return theList;
	}
	return 0;
}

pascal Boolean formatFilter(DialogPtr dialog,EventRecord *theEvent,short *itemHit)
{
	ListHandle *lists;
	Point mouseLoc,cell;
	short modifiers;
	Rect box;
	short itemType;
	char key;
	Handle itemHand;
	Boolean selected;
	
	SetPortDialogPort (dialog);

	cell.h=cell.v=0;
	lists=(ListHandle *)GetWRefCon (GetDialogWindow (dialog));
	selected=LGetSelect(true,&cell,lists[0]);
	
	if(theEvent->what==mouseDown) {
		mouseLoc=theEvent->where;
		modifiers=theEvent->modifiers;
		GlobalToLocal(&mouseLoc);
		GetDialogItem(dialog,10,&itemType,&itemHand,&box);
		if(PtInRect(mouseLoc,&box)) {
			if(LClick(mouseLoc,modifiers,lists[0])) {	/* Double Click */
				*itemHit=1;
				return true;
			}
		}
		GetDialogItem(dialog,11,&itemType,&itemHand,&box);
		if(PtInRect(mouseLoc,&box)) {
			if(LClick(mouseLoc,modifiers,lists[1])) {	/* Double Click */
				*itemHit=1;
				return true;
			}
		}
	} else if(theEvent->what==keyDown) {
		if(DialogStandardKeyDown(dialog,theEvent,itemHit))
			return true;
		key=theEvent->message&charCodeMask;
		if(isdigit(key) || key==TAB || key==DELETE) {
			return false;
		} else
			return true;
	}
	GetDialogItem(dialog,1,&itemType,&itemHand,&box);
	HiliteControl((ControlHandle)itemHand,(selected)? 0:255);
	return false;
}


static void doFormatDialog (DocumentPtr doc)
{
	TE32KHandle tH;
	DialogPtr formatDialog;
	short itemHit,itemType,dataLen,fontNum;
	Boolean noWordWrap,calText=false,pau=false,showInvisibles;
	Boolean autoIndent,wrapToLength,wrapText;
	Handle itemHand;
	ListHandle lists[2];
	Point fontCell,tempCell,sizeCell;
	long textSize,tabChars,lineLength;
	Rect box;
	Str255 numStr;

	if(tH= doc->docData) {
		formatDialog=GetNewDialog(144, nil, (WindowPtr)(-1));
		if(!formatDialog) {
			SysBeep(3);SysBeep(3);SysBeep(3);
			return;
		}
	
		if(lists[0]=FillFontList(formatDialog,(**tH).txFont,&fontCell)) {
	
			noWordWrap=(**tH).crOnly;
			wrapToLength=(**tH).wrapToLength;
			autoIndent=(**tH).autoIndent;
			lineLength=((**tH).maxLineWidth==kMaxShort)? 75:(**tH).maxLineWidth;
			showInvisibles=(**tH).showInvisibles;

			SetWRefCon(GetDialogWindow (formatDialog),(long)lists);
			LAutoScroll(lists[0]);
			UpdateList(lists[0]);

			GetDialogItem(formatDialog,19,&itemType,&itemHand,&box);
			SetDialogItem(formatDialog,19,itemType,(Handle)doButtonUPP,&box);
			
			GetDialogItem(formatDialog,18,&itemType,&itemHand,&box);
			SetDialogItem(formatDialog,18,itemType,(Handle)doFrameUPP,&box);
			
			GetDialogItem(formatDialog,4,&itemType,&itemHand,&box);
			NumToString((**tH).tabChars,numStr);
			SetDialogItemText(itemHand,numStr);
			
			GetDialogItem(formatDialog,9,&itemType,&itemHand,&box);
			NumToString((**tH).txSize,numStr);
			SetDialogItemText(itemHand,numStr);
			
			GetDialogItem(formatDialog,15,&itemType,&itemHand,&box);
			NumToString(lineLength,numStr);
			SetDialogItemText(itemHand,numStr);
			
			lists[1]=0;
#if 0
			UpdateSizeList(formatDialog,(**tH).txFont,&lists[1]);
			LAutoScroll(lists[1]);
			UpdateList(lists[1]);
#endif
			sizeCell.v=-1;
						
			while(!pau) {
			
				/* Do the check boxes */
				
				GetDialogItem(formatDialog,5,&itemType,&itemHand,&box);
				SetControlValue((ControlHandle)itemHand,showInvisibles);
				
				GetDialogItem(formatDialog,6,&itemType,&itemHand,&box);
				SetControlValue((ControlHandle)itemHand,!noWordWrap);
				
				GetDialogItem(formatDialog,16,&itemType,&itemHand,&box);
				SetControlValue((ControlHandle)itemHand,autoIndent);
				
				/* Do the radio buttons */
				
				GetDialogItem(formatDialog,12,&itemType,&itemHand,&box);
				SetControlValue((ControlHandle)itemHand,!wrapToLength);
				HiliteControl((ControlHandle)itemHand,(noWordWrap)?255:0);
				
				GetDialogItem(formatDialog,13,&itemType,&itemHand,&box);
				SetControlValue((ControlHandle)itemHand,wrapToLength);
				HiliteControl((ControlHandle)itemHand,(noWordWrap)?255:0);

				tempCell=LLastClick(lists[0]);
				if(tempCell.v!=fontCell.v) {
					fontCell=tempCell;
					dataLen=255;
					LGetCell(numStr+1,&dataLen,fontCell,lists[0]);
					*numStr=dataLen;
					GetFNum(numStr,&fontNum);
					UpdateSizeList(formatDialog,fontNum,&lists[1]);
					LAutoScroll(lists[1]);
					UpdateList(lists[1]);
				}
				ModalDialog(formatFilterUPP,&itemHit);
		
				switch(itemHit) {
					case 1:
						GetDialogItem(formatDialog,4,&itemType,&itemHand,&box);
						GetDialogItemText(itemHand,numStr);
						StringToNum(numStr,&tabChars);
						GetDialogItem(formatDialog,15,&itemType,&itemHand,&box);
						GetDialogItemText(itemHand,numStr);
						StringToNum(numStr,&lineLength);
						
						if(tabChars>0 && lineLength>0) {
							pau=true;
							(**tH).tabChars=tabChars;
							(**tH).tabWidth=tabChars * (**tH).theCharWidths[' '];
						} else {
							SelectDialogItemText(formatDialog,4,0,kMaxShort);
							SysBeep(7);
						}
						break;
					case 2:
						LDispose(lists[0]);
						LDispose(lists[1]);
						DisposeDialog (formatDialog);
						return;
					case 5:			/* Show Invisibles */
						showInvisibles=!showInvisibles;
						break;
					case 6:			/* Word Wrap */
						noWordWrap=!noWordWrap;
						break;
					case 11:
						tempCell.h=tempCell.v=0;
						if(LGetSelect(true,&tempCell,lists[1])) {
							sizeCell=tempCell;
							dataLen=255;
							LGetCell(numStr+1,&dataLen,sizeCell,lists[1]);
							*numStr=dataLen;
							GetDialogItem(formatDialog,9,&itemType,&itemHand,&box);
							SetDialogItemText(itemHand,numStr);
							SelectDialogItemText(formatDialog,9,0,kMaxShort);
						}
						break;
					case 12:
						wrapToLength=0;
						break;
					case 13:
						wrapToLength=1;
						break;
					case 16:
						autoIndent=!autoIndent;
						break;
					default:
						break;
				}
			}
			
			tempCell.h=tempCell.v=0;
			fontNum=(**tH).txFont;
			if(LGetSelect(true,&tempCell,lists[0])) {
				dataLen=255;
				LGetCell(numStr+1,&dataLen,tempCell,lists[0]);
				*numStr=dataLen;
				GetFNum(numStr,&fontNum);
			}
			
			GetDialogItem(formatDialog,9,&itemType,&itemHand,&box);
			GetDialogItemText(itemHand,numStr);
			StringToNum(numStr,&textSize);			

			LDispose(lists[0]);
			LDispose(lists[1]);
			DisposeDialog (formatDialog);
			
			if((**tH).txFont!=fontNum || (**tH).txSize!=textSize || (**tH).showInvisibles!=showInvisibles) {
				calText=true;
				(**tH).showInvisibles=showInvisibles;
				TE32KSetFontStuff(fontNum,(**tH).txFace,(**tH).txMode,(short)textSize,tH);
			}
			
			(**tH).autoIndent=autoIndent;
			wrapText = noWordWrap!=(**tH).crOnly 
							|| wrapToLength!=(**tH).wrapToLength
							|| (wrapToLength && (**tH).maxLineWidth!=lineLength);
							
			(**tH).maxLineWidth=lineLength;
			
			if(calText || (**tH).showInvisibles!=showInvisibles || wrapText) {
				if(!noWordWrap || noWordWrap!=(**tH).crOnly) 
					SetControlValue(doc->hScroll,0);
					
				(**tH).crOnly=noWordWrap;
				(**tH).wrapToLength=wrapToLength;
				SetTE32KRect(doc);
				TE32KSelView (tH);
				SetPortWindowPort (doc->docWindow);
				METHOD_GetContentRect(doc,&box);
				InvalRect(&box);
				EraseRect(&box);
			}
		}
	}
}


/****************************************************************************
**
**  Search functions and dialog for text windows
*/
long forSearch(char *buf, char *end, const char *what, long len)    /*BH: inserted const (because used with const arg below */
{
	long i,offset;
	
	for(offset=0;buf<end;buf++,offset++) {
		if(UPPERCASE(*buf) == UPPERCASE(*what)) {
			for(i=1;i<len;i++) {
				if(UPPERCASE(*(buf+i)) != UPPERCASE(*(what+i)))
					goto NoMatch;
			}
			return offset;
		}
NoMatch:	;
	}
	return -1;
}

long forCSSearch(char *buf, char *end, const char *what, long len)      /*BH: inserted const (because used with const arg below */
{
	long i,offset;
	
	for(offset=0;buf<end;buf++,offset++) {
		if(*buf == *what) {
			for(i=1;i<len;i++) {
				if(*(buf+i) != *(what+i))
					goto NoMatch;
			}
			return offset;
		}
NoMatch:	;
	}
	return -1;
}

long revSearch(char *buf, char *start, const char *what, long len) /*BH: inserted const (because used with const arg below */
{
	long i,offset;
	
	for(offset=-1;buf>=start;buf--,offset--) {
		if(UPPERCASE(*buf) == UPPERCASE(*what)) {
			for(i=1;i<len;i++) {
				if(UPPERCASE(*(buf+i)) != UPPERCASE(*(what+i)))
					goto NoMatch;
			}
			return offset;
		}
NoMatch:	;
	}
	return 0;
}

long revCSSearch(char *buf, char *start, const char *what, long len)  /*BH: inserted const (because used with const arg below */
{
	long i,offset;
	
	for(offset=-1;buf>=start;buf--,offset--) {
		if(*buf == *what) {
			for(i=1;i<len;i++) {
				if(*(buf+i) != *(what+i))
					goto NoMatch;
			}
			return offset;
		}
NoMatch:	;
	}
	return 0;
}

long RSearch(Handle h,long offset,const char *what,long len)
{
	long where,notFound;
	
	HLock(h);
	notFound = (gSearchMethod==1);
	do {
		where = (gCaseSensitive)? 
					revCSSearch(*h+offset-1,*h,what,len) : 
					revSearch(*h+offset-1,*h,what,len) ;
		offset+=where;
		if(where) {
			if(gSearchMethod==1) {		/* Whole word */
				if(isIdChar(*(*h+offset+len)) || (offset && isIdChar(*(*h+offset-1)))) 
					;
				else
					notFound = 0;	/* Trip out */
			}
		} else
			notFound = 0;
	} while (notFound) ;
	HUnlock(h);
	return (where)? offset : -1;
}

char *matchLiteral(char *buf,char *lit,long *foundLen,long *litLen)
{
	unsigned char *p,*match;
	long len1=0,len2=0;
	Str255 searchStr;
	
	/* fill the search string */
	p=searchStr;
	while(*lit && *lit!='*' && *lit!='‰' && *lit!='?' && *lit!='[') {
		*p++ = *lit ++;
		len1++;
		len2++;
	}
	*p='\0';
	*foundLen+=len1;
	*litLen+=len2;
	if(gCaseSensitive) {
		p=searchStr;
		while(*buf) {
			while(*buf && *p!=*buf) buf++;
			if(*(match=(unsigned char*)buf)) {
				p++;
				buf++;
				while(*p) {
					if(*p!=*buf) {
						p=searchStr;
						buf++;
						match=0;
						break;
					}
					p++;
					buf++;
				}
				if(!*p)
					break;
			}
		}
	} else {
		for(p=searchStr;*p;p++)
			*p=UPPERCASE(*p);
		p=searchStr;
		while(*buf) {
			while(*buf && *p!=UPPERCASE(*buf)) buf++;
			if(*(match=(unsigned char*)buf)) {
				p++;
				buf++;
				while(*p) {
					if(*p!=UPPERCASE(*buf)) {
						p=searchStr;
						buf++;
						match=0;
						break;
					}
					p++;
					buf++;
				}
				if(!*p)
					break;
			}
		}
	}
	if(match) {
		len1=len2=0;
		if(matchExpressionRight(buf,lit+len2,&len1,&len2)) {
			*foundLen+=len1;
			*litLen+=len2;
			return (char*)match;
		}
	}
	return 0;
}

char *matchRange(char *buf,char *lit,long *foundLen,long *rangeLen)
{
	unsigned char *p,*match;
	long len1=0,len2=0,repeats=false;
	Str255 searchStr;
	
	/* fill the search string */
	p=searchStr;
	while(*lit && *lit!=']') {
		*p++ = *lit ++;
		len2++;
	}
	if(!*lit) {
		return 0;
	}
	len2++;
	if(*(p-1)=='*') {
		repeats=true;
		p--;
	}
	*p='\0';
	
	/* match=strpbrk(buf,(char *) searchStr) */
	match = (unsigned char*)buf;
	while (*match) {
		for (p = searchStr; *p != '\0' && *p != *match; p++);
		if (*p)
			break;
		match++;
	}
	
	if(*match) {
		if (repeats) {
			len1 = 0;
			do {
				len1++;
				match++;
				for (p = searchStr; *p != '\0' && *p != *match; p++);
			} while (*p);
		} else 
			len1 = 1;
		*foundLen+=len1;
		len1=len2=0;
		if(matchExpressionRight(buf+len1,lit+len2,&len1,&len2)) {
			*foundLen+=len1;
			*rangeLen+=len2;
			return (char*)match;
		}
	}
	return 0;
}

char *matchExpressionRight(char *buf,char *exp,long *foundLen,long *expLen)
{
	char *anchor,*start,*match;
	Boolean doLeft=false;
	
	anchor=exp;
	start=buf;
	for(;;) {
		if(*anchor=='?') {
			start++;
			doLeft=true;
		} else if(*anchor=='*' || *anchor=='‰')    /*BH: anchor == -> *anchor == */
			doLeft=true;
		else
			break;
		anchor++;
	}
	if(!*anchor)
		match=start;
	else if(*anchor=='[') 
		match=matchRange(start,anchor+1,foundLen,expLen);
	else
		match=matchLiteral(start,anchor,foundLen,expLen);
	if(match && doLeft) {
		while(anchor>exp) {
			anchor--;
			if(*anchor=='?') {
				match--;
				(*foundLen)++;
				(*expLen)++;
			} else if(*anchor=='*' || *anchor=='‰') {
				while(match>buf && *match!='\n') {
					match--;
					(*foundLen)++;
				}
				if(*match=='\n') {
					match++;
					(*foundLen)--;
				}
			}
			(*expLen)++;
		}
	}
	return match;
}

long ExpressionMatch(char *buf,char *end,char *exp,long *expLen)
{
	
	char storage,*found;
	long len1=0,len2=0;
	
	storage = *(end-1);
	*(end-1)='\0';
	found=matchExpressionRight(buf,exp,&len1,&len2);
	*expLen=len1;
	*(end-1)=storage;
	if(found)
		return found-buf+1;
	else
		return -1;
}

long ExpressionSearch(Handle h, long hLen, long offset,const char *what,long *len)
{
	long where,foundLen;
	Str255 expressionString;
	
	BlockMove(what,expressionString,*len);
	*(expressionString+*len)='\0';
	HLock(h);
	where = ExpressionMatch(*h+offset+1,*h+hLen,(char *) expressionString,&foundLen);
	offset+=where;
	*len=foundLen;
	if(where && gSearchMethod==1) {
		if(isIdChar(*(*h+offset+*len-1)) || (offset<hLen && isIdChar(*(*h+offset+1)))) {
			HUnlock(h);
			return -1;
		}
	}	
	HUnlock(h);
	return (where)? offset : -1;
}

long FSearch(Handle h,long hLen, long offset,const char *what,long len)
{
	long where;
	
	HLock(h);
	
	do {
		where = (gCaseSensitive)? 
					forCSSearch(*h+offset,*h+hLen,what,len) : 
					forSearch(*h+offset,*h+hLen,what,len) ;
		if(where>=0) {
			offset+=where;
			if(where && gSearchMethod==1) {
				if(isIdChar(*(*h+offset-1)) || 
					((offset+len)<hLen && isIdChar(*(*h+offset+len)))) 
						offset+=len;
				else
					where = -1; /* Trip out */
			} else 
				where = -1;		/* Found string. Trip out. */
		} else /* where == -1 means string not found. Exit. */
			offset = -1;
	} while (where>=0) ;
	HUnlock(h);
	return offset;
}

static Boolean findSearchString (DocumentPtr doc, short direction)
{
	long where,end,lastLine,foundLength;
	TE32KHandle tH;

	if(tH= doc->docData) {
		if(gSearchMethod==2) {	/* Selection expression */
			if(isdigit(*(gFindBuffer+1))) {
				lastLine=(**tH).nLines-1;
				/* Since nLines isn¹t right if the last character is a return, check for that case.
					(hint from TESample example. */
				if ( *(*(**tH).hText + (**tH).teLength - 1) == '\n' )
					lastLine++;
				
				*(gFindBuffer + *gFindBuffer + 1) = '\0';
				where=atoi((char *) gFindBuffer+1);
				where=(where>lastLine)? lastLine : where ;
				where=(where<=0)? 1 : where;
				end = (**tH).lineStarts[where];
				where = (**tH).lineStarts[where-1];
			} else {
				foundLength=*gFindBuffer;
				where=ExpressionSearch((**tH).hText,(**tH).teLength, (**tH).selEnd,(char *) gFindBuffer+1,&foundLength);
				if(where<0 && gWrapSearch) {	/* not found, try one more time, from start */
					foundLength=*gFindBuffer;
					where=ExpressionSearch((**tH).hText,(**tH).teLength, 0,(char *) gFindBuffer+1,&foundLength);
					if(where==(**tH).selStart && foundLength==((**tH).selEnd-(**tH).selStart))
						where=-1;
				}
				end = where + foundLength;
			}
		} else {
			if((direction)? !gSearchBackwards : gSearchBackwards)
				where=RSearch((**tH).hText,(**tH).selStart,(char *) gFindBuffer+1,(long)*gFindBuffer);
			else
				where=FSearch((**tH).hText,(**tH).teLength, (**tH).selEnd,(char *) gFindBuffer+1,(long)*gFindBuffer);
			if(where<0 && gWrapSearch) {	/* not found, try one more time, from start */
				if((direction)? !gSearchBackwards : gSearchBackwards)
					where=RSearch((**tH).hText,(**tH).teLength,(char *) gFindBuffer+1,(long)*gFindBuffer);
				else
					where=FSearch((**tH).hText,(**tH).teLength, 0,(char *) gFindBuffer+1,(long)*gFindBuffer);
				if(where==(**tH).selStart && *gFindBuffer==((**tH).selEnd-(**tH).selStart))
					where=-1;
			}
			end = where + *gFindBuffer;
		}
		if(where>=0 && where <(**tH).teLength) {
			TE32KSetSelect(where,end,tH);
			doc->fHaveSelection = 1;
			return true;
		}
		SysBeep(7);
	}
	return false;
}

pascal Boolean DialogStandardKeyDown(DialogPtr dialog, EventRecord *theEvent, short *itemHit)
{
	Rect box;
	Handle itemHand;
	short itemType;
	char key;
	
	if(theEvent->what==keyDown) {
		key=theEvent->message&charCodeMask;
		switch(key) {
			case 3: case 13:		/* Enter or CR */
				GetDialogItem(dialog,1,&itemType,&itemHand,&box);
				HiliteControl((ControlHandle)itemHand,1);
				*itemHit=1;
				return true;
			case 46:				/* Period */
				if(theEvent->modifiers&0x100) {
			case 27:				/* Escape */
					GetDialogItem(dialog,2,&itemType,&itemHand,&box);
					HiliteControl((ControlHandle)itemHand,2);
					*itemHit=2;
					return true;
				}
			default:
				return false;
		}
	}
	return false;
}

static Boolean doFindDialog(short which)
{
	DialogPtr findDialog;
	short itemHit;
	short itemType;
	Handle itemHand;
	Boolean pau=false,result=false;
	Rect box;

	findDialog=GetNewDialog(which, nil, (WindowPtr)(-1));
	/* Note: map Dialog is 137 */
	if(!findDialog) {
		SysBeep(3);SysBeep(3);SysBeep(3);
		return false;
	}

	GetDialogItem(findDialog,11,&itemType,&itemHand,&box);
	SetDialogItem(findDialog,11,itemType,(Handle)doLineUPP,&box);
	GetDialogItem(findDialog,12,&itemType,&itemHand,&box);
	SetDialogItem(findDialog,12,itemType,(Handle)doLineUPP,&box);
	GetDialogItem(findDialog,13,&itemType,&itemHand,&box);
	SetDialogItem(findDialog,13,itemType,(Handle)doButtonUPP,&box);
	GetDialogItem(findDialog,4,&itemType,&itemHand,&box);
	SetDialogItemText(itemHand,gFindBuffer);
	SelectDialogItemText(findDialog,4,0,kMaxShort);
	while(!pau) {
		/* Initialize the three radio buttons */
		GetDialogItem(findDialog,5,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gSearchMethod==0);
		GetDialogItem(findDialog,6,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gSearchMethod==1);
		GetDialogItem(findDialog,7,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gSearchMethod==2);
		/* Do the check boxes */
		GetDialogItem(findDialog,8,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gCaseSensitive);
		GetDialogItem(findDialog,9,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gSearchBackwards);
		GetDialogItem(findDialog,10,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gWrapSearch);
		
		ModalDialog(DialogStandardFilterUPP,&itemHit);

		switch(itemHit) {
			case 1:
				pau=true;
				GetDialogItem(findDialog,4,&itemType,&itemHand,&box);
				GetDialogItemText(itemHand,gFindBuffer);
				result=true;;
				break;
			case 2:
				pau=true;
				break;
			case 5:			/* Survey or Literal Radio Button */
				gSearchMethod=0;
				break;
			case 6:			/* Station or Entire Word */
				gSearchMethod=1;
				break;
			case 7:			/* Selection Expression */
				gSearchMethod=2;
				break;
			case 8:			/* Select All or Case Sensitive */
				gCaseSensitive = !gCaseSensitive;
				break;
			case 9:			/* Center Selection or Search Backwards */
				gSearchBackwards = !gSearchBackwards;
				break;
			case 10:		/* Scale to fit or Wrap-Around Search */
				gWrapSearch = !gWrapSearch;
				break;
			default:
				break;
		}
	}
	DisposeDialog (findDialog);
	return result;
}

short doReplaceDialog(void)
{
	DialogPtr replaceDialog;
	short itemHit;
	short itemType;
	Handle itemHand;
	Boolean pau=false;
	Rect box;
	
	replaceDialog=GetNewDialog(133, nil, (WindowPtr)(-1));
	if(!replaceDialog) {
		SysBeep(3);SysBeep(3);SysBeep(3);
		return 2; /* cancel */
	}

	GetDialogItem(replaceDialog,15,&itemType,&itemHand,&box);
	SetDialogItem(replaceDialog,15,itemType,(Handle)doLineUPP,&box);
	GetDialogItem(replaceDialog,16,&itemType,&itemHand,&box);
	SetDialogItem(replaceDialog,16,itemType,(Handle)doLineUPP,&box);
	GetDialogItem(replaceDialog,17,&itemType,&itemHand,&box);
	SetDialogItem(replaceDialog,17,itemType,(Handle)doButtonUPP,&box);

	GetDialogItem(replaceDialog,4,&itemType,&itemHand,&box);
	SetDialogItemText(itemHand,gFindBuffer);
	SelectDialogItemText(replaceDialog,4,0,kMaxShort);

	GetDialogItem(replaceDialog,6,&itemType,&itemHand,&box);
	SetDialogItemText(itemHand,gReplaceBuffer);

	while(!pau) {
		/* Initialize the three radio buttons */
		GetDialogItem(replaceDialog,9,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gSearchMethod==0);
		GetDialogItem(replaceDialog,10,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gSearchMethod==1);
		GetDialogItem(replaceDialog,11,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gSearchMethod==2);
		/* Do the check boxes */
		GetDialogItem(replaceDialog,12,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gCaseSensitive);
		GetDialogItem(replaceDialog,13,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gSearchBackwards);
		GetDialogItem(replaceDialog,14,&itemType,&itemHand,&box);
		SetControlValue((ControlHandle)itemHand,gWrapSearch);

		ModalDialog(DialogStandardFilterUPP,&itemHit);

		switch(itemHit) {
			case 1: case 7: case 8:	/* Replace, Replace All, Find */
				pau=true;
				GetDialogItem(replaceDialog,4,&itemType,&itemHand,&box);
				GetDialogItemText(itemHand,gFindBuffer);
				GetDialogItem(replaceDialog,6,&itemType,&itemHand,&box);
				GetDialogItemText(itemHand,gReplaceBuffer);
				break;
			case 2:
				pau=true;
				break;
			case 9:			/* Literal Radio Button */
				gSearchMethod=0;
				break;
			case 10:		/* Entire Word */
				gSearchMethod=1;
				break;
			case 11:		/*  Selection Expression */
				gSearchMethod=2;
				break;
			case 12:		/* Case Sensitive */
				gCaseSensitive = !gCaseSensitive;
				break;
			case 13:		/* Search Backwards */
				gSearchBackwards = !gSearchBackwards;
				break;
			case 14:		/* Wrap-Around Search */
				gWrapSearch = !gWrapSearch;
				break;
			default:
				SysBeep(7);
				break;
		}
	}
	CloseDialog (replaceDialog);
	return itemHit;
}
