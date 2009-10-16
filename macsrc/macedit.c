/****************************************************************************
**
*W  macedit.c                   GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the built-in text editor.
**
**  It is based upon version 1.2.1 of Plain Text, a freeware text editor by 
**  Mel Park.
**	
**	The style of coding in which Plain Text is written is a bit unusual. 
**	It is a pure C implimentation of ideas contained in the object class 
**	library published in "Elements of C++ Macintosh Programming" by Dan 
**	Weston. Objects are implemented as structures and member functions 
**	are implemented as pointers to subroutines contained within the object 
**	structure. Consider it assembly-language C++.
**	
**	The text engine (in the file 'macte.c') is from TE32K, by Roy Wood. 
**  Mel Park has extensively modified it for the family of applications 
**  related to PlainText.
*/
#if !TARGET_API_MAC_CARBON
#include <AppleEvents.h>
#include <Balloons.h>
#include <Controls.h>
#if UNIVERSAL_INTERFACES_VERSION >= 0x0330  
	#include <ControlDefinitions.h>
#endif
#include <files.h>
#include <Fonts.h>
#include <Gestalt.h>
#include <Lists.h>
#include <LowMem.h>
#include <Menus.h>
#include <QuickDraw.h>
#include <StandardFile.h>
#include <String.h>
#include <Sound.h>
#include <OSUtils.h>

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

#include <stdio.h>
#include <ctype.h>
#endif

#include "macdefs.h"
#include "macte.h"
#include "macedit.h"
#include "macdocs.h"
#include "maccon.h"
#include "system.h"
#include "macintr.h"


/*---------------------------- Global variables ----------------------------*/

MenuHandle DeskMenu;              /* handles for menus */
MenuHandle FileMenu;
MenuHandle EditMenu;
MenuHandle FindMenu;
#if MARKS
MenuHandle MarkMenu;
#endif
MenuHandle WindowMenu;

#ifdef GAPVER
MenuHandle HelpMenu;
#endif

short gNumberSystemHelpItems;
Str255 gFindBuffer = "\p";                 /* contain find and replace strings */
Str255 gReplaceBuffer = "\p";

Handle PTScratch;

Boolean gPlainTextIsRunning = true;
short gEditorResRefNum;  /* resource file ref num of application */
short gSearchMethod = 0;

long gPrintBufferSize = 64L*1024L; /* this should be a fairly safe value */

Boolean gSearchBackwards = false;
Boolean gCaseSensitive = false;
Boolean gWrapSearch = false;

DocumentRecord Documents[MAXWINDS];

DocumentPtr gClipboardDoc = 0;
	
Rect gDefaultDocRect = {40, 5, 342, 512};  /*BH: inserted */
	
short NumFileTypes = 1;
SFTypeList MyFileTypes = {'TEXT', 0 ,0, 0 };

Boolean gHasColorQD;
Boolean gHasDrag;
Boolean gMacPlusKBD;
Boolean gHasTranslationMgr;
Boolean gInBackground = false;  /*BH: false inserted */
Boolean gError = false;   /* true if a doMessage occurs */
Boolean gDAonTop;
FSSpec DefaultSpecs;
FSSpec HomeSpecs;

/* to pass values into callback routines */
EventRecord *gCurrentEvent;
DocumentPtr gCurrentDocument = NULL;
short gCurrentControlValue, gCurrentScrollAmount;

ModalFilterUPP DialogStandardFilterUPP, SimpleDialogFilterUPP,formatFilterUPP;
ControlActionUPP myControlActionUPP; 	
UserItemUPP doLineUPP, doButtonUPP, doFrameUPP;

Str255 gUppercaseTable;

#if TEMPMEM
OSErr gMemError;
#endif

/****************************************************************************
**
** 	callback routines
*/
pascal Boolean SimpleDialogFilter(DialogPtr dialog, EventRecord *theEvent, short *itemHit)
{
#pragma unused(dialog)
	char key;
	
	if(theEvent->what==keyDown) {
		key=theEvent->message&charCodeMask;
		switch(key) {
			case 3: case 13:		/* Enter or CR */
				*itemHit=1;
				return true;
			case 46:				/* Period */
				if(theEvent->modifiers&0x100) {
			case 27:				/* Escape */
					*itemHit=2;
					return true;
				}
			default:
				return false;
		}
	}
	return false;
}


pascal void doButton(DialogPtr theDialog,short s)  /*BH: s inserted */
{
	short itemType;
	Handle itemHand;
	Rect box;

	GetDialogItem(theDialog,1,&itemType,&itemHand,&box);
	PenSize(3,3);
	InsetRect(&box,-4,-4);
	FrameRoundRect(&box,16,16);
}

pascal void doFrame(DialogPtr theDialog,short item)
{
	short itemType;
	Handle itemHand;
	Rect box;

	GetDialogItem(theDialog,item,&itemType,&itemHand,&box);
	PenSize(1,1);
	FrameRect(&box);
}

pascal void doLine(DialogPtr theDialog,short item)
{
	short itemType;
	Handle itemHand;
	Rect box;

	GetDialogItem(theDialog,item,&itemType,&itemHand,&box);
	PenSize(1,1);
	MoveTo(box.left,box.top);
	LineTo(box.right,box.top);
}


/****************************************************************************
**
** 	message functions
*/

void GetUserAttention (void)
{
	NMRec theNMRec;
	OSErr err;
	Boolean oldGAPIsIdle;
	Handle iconHandle;
	
	if (!gInBackground)
		return;
	if ((err = GetIconSuite (&iconHandle, 128, kSelectorAllSmallData)) != noErr)
		iconHandle = 0;
	theNMRec.qType = nmType;
	theNMRec.nmMark = 1; 
	theNMRec.nmIcon = iconHandle;
	theNMRec.nmSound = (Handle) -1; /* play system sound */
	theNMRec.nmStr = "\pGAP requires your attention"; 
	theNMRec.nmResp = NULL;
	theNMRec.nmRefCon = 0;
	
	err = NMInstall (&theNMRec);
	
	oldGAPIsIdle = gGAPIsIdle;

	while (gInBackground)
		ProcessEvent ();

	gGAPIsIdle = oldGAPIsIdle;
	
	if (err == noErr)
		err = NMRemove (&theNMRec);	
		
	if (iconHandle)
		err = DisposeIconSuite (iconHandle, true);
}
		
void doMessage(short message)	/* Uses Str resource 130 */ 
{
	DialogPtr dialogPtr;
	short itemType;
	Rect box;
	Handle itemHand;
	Str255 buf;

	GetUserAttention ();
	
	gError = true;  /* in any case, signal an error to the main program */
	GetIndString(buf,130,message);
	ParamText(buf, "\p", "\p", "\p");
	dialogPtr=GetNewDialog(MessageDialog, nil ,(WindowPtr)-1);
	if (dialogPtr) {
		GetDialogItem(dialogPtr,4,&itemType,&itemHand,&box);
		SetDialogItem(dialogPtr,4,itemType,(Handle)doButtonUPP,&box);
		InitCursor();
		ModalDialog(SimpleDialogFilterUPP,&itemType);   /* BH: changed SimpleDialogFilter to SimpleDialogFilterUPP */
		DisposeDialog(dialogPtr);
	} else {
		SysBeep(3);SysBeep(3);SysBeep(3);
	}
}

void doDiagnosticMessage(short message, short errNum)
{
	DialogPtr dialogPtr;
	short item;
	Str255 buf,num;
#if ASCONSOLE    
	errdesc * desc;
#endif
	char * p;
	long len;
	unsigned char * q;
	
	GetUserAttention ();

	GetIndString(buf,130,message);

#if ASCONSOLE        
    desc = gMacOSErrDesc;
    while (desc->code && desc->code != errNum)
    	desc++;
	p = desc->code? desc->description: "Unknown Mac error code";
#else
	p = "Error code";
#endif
	for (len = 1; *p && len < sizeof (num)-20; )
		num[len++] = (unsigned char) *p++;
	num[len++] = ' ';

	NumToString(errNum,num+len);  /* insert number as pascal string */
	q = num + len;
	len += *q;
	*q = '(';   /* overwrite length byte */
	num[++len] = ')';
	num[0] = len;   /* insert length of string in num */

	ParamText(buf,num,"\p", "\p");
	dialogPtr=GetNewDialog(MessageDialog, nil, (WindowPtr)-1);
	if (dialogPtr) {
		InitCursor();
		ModalDialog(SimpleDialogFilterUPP,&item);   /* BH: changed SimpleDialogFilter to SimpleDialogFilterUPP */
		DisposeDialog(dialogPtr);
	} else {
		SysBeep(3);SysBeep(3);SysBeep(3);
	}
}

Boolean doConfirmDialog(short strID,Str255 message)
{
	DialogPtr confirmDialog;
	short itemHit,itemType;
	Handle itemHand;
	Rect box;
	Str255 buf;

	GetUserAttention ();

	GetIndString(buf,128,strID);

	ParamText (message, 0,0,0);
	confirmDialog=GetNewDialog(rConfirmDialog, nil, (WindowPtr)(-1));

	if(!confirmDialog) {
		SysBeep(3);SysBeep(3);SysBeep(3);
		return false;
	}

	if(!confirmDialog) {
		SysBeep(3);SysBeep(3);SysBeep(3);
		return false;
	}

	GetDialogItem(confirmDialog,3,&itemType,&itemHand,&box);
	SetDialogItemText(itemHand,buf);
	GetDialogItem(confirmDialog,4,&itemType,&itemHand,&box);
	SetDialogItem(confirmDialog,4,itemType,(Handle)doButtonUPP,&box);
		
	
	for(;;) {
		ModalDialog(DialogStandardFilterUPP,&itemHit);   /* BH: replaced DialogStandardFilter by DialogStandardFilterUPP */
		
		if(itemHit==iYes) {				/* Okay */
			DisposeDialog (confirmDialog);
			return true;
		} else if(itemHit==iNo) {
			DisposeDialog (confirmDialog);
			return false;
		}
	}
}

void FatalError(void)
{
	SysBeep(5);SysBeep(5);SysBeep(5);SysBeep(5);SysBeep(5);  /* BH: beep five times */
	ExitToShell();
}

/****************************************************************************
**
** 	routines for animated cursor
*/
#if BEACHBALL

#include <Resources.h>
#include <Memory.h>
#include <Events.h>
#include <Desk.h>

/*---------------------------------- static typedefs --------------------------------*/
typedef struct Acur
{
	short totalFrames;	/* number of cursor frames */
	short currentFrame;	/* the currently shown frame */
	long frame[32];		/* high word has the ID */
}Acur;
	
/*---------------------------------- static variables -------------------------------*/

static long SpinCount=10;
static long count;
static Acur aCurs;
static Acur *aCursR=&aCurs;
static Boolean calledBefore=false;
static Boolean showACurs=false;
static Boolean aCursGoing=false;

/*--------------------------- Externally visible subroutines ------------------------*/
int InitACurs(int id)
{
	int i;
	Handle cHandle;
	
	/* release any acurs handles we already got */
	if (calledBefore)
	{
		for (i=0;i<aCurs.totalFrames;i++)
			ReleaseResource((Handle)(aCurs.frame[i]));
	}
	
	/* get the acur resource */
	UseResFile (gEditorResRefNum);
	cHandle=GetResource('acur',id);
	if (cHandle == NULL) return(-1);	/* @#!$$@^*& no resource there!! */
	
	/* load it into the record for this code */
	HLock(cHandle);
	aCursR=(Acur*)*cHandle;
	aCurs.totalFrames=aCursR->totalFrames;
	if (aCurs.totalFrames>32) return(-2); /* something wrong with this resource */
	for (i=0;i<aCursR->totalFrames;i++)
		aCurs.frame[i]=aCursR->frame[i];
	HUnlock(cHandle);
	ReleaseResource(cHandle);
	
	/* now we gotta pick up each of the cursors */
	for (i=0;i<aCurs.totalFrames;i++)
	{
		aCurs.frame[i]=(long)GetCursor(HiWord(aCurs.frame[i]));
		if (aCurs.frame[i]==0) return(-3);
	}
	calledBefore=true;
	aCurs.currentFrame=0;
	aCursGoing=true;
	ShowACurs();
}
	
int SpinACurs(int increment)
{
	Cursor *curs;

	if (increment!=0)
		count+=increment;
	else
		count++;
	if (count<SpinCount) return(false);
	minimain(); 	/* take care of update and suspend/resume events */
	
	/* if showing it, unlock the old cursor */
	if (showACurs)
		HUnlock((Handle)(aCurs.frame[aCurs.currentFrame]));
	/* move cursor to the next frame */
	aCurs.currentFrame++;
	if (aCurs.currentFrame>=aCurs.totalFrames) aCurs.currentFrame=0;
	
	/* and show it if necessary */
	if (showACurs)
	{
		HLock((Handle)(aCurs.frame[aCurs.currentFrame]));
		curs=*((CursHandle)(aCurs.frame[aCurs.currentFrame]));
		SetCursor(curs);
	}
	count=0;
	return(true);
}
	
void ShowACurs(void)
{
	Cursor *curs;
	
	showACurs=true;
	HLock((Handle)aCurs.frame[aCurs.currentFrame]);
	curs=*((CursHandle)(aCurs.frame[aCurs.currentFrame]));
	SetCursor(curs);
}

void HideACurs(void)
{
	showACurs=false;
	HUnlock((Handle)(aCurs.frame[aCurs.currentFrame]));
	aCursGoing=false;
}

int ACursGoing(void)
{
	return(aCursGoing);
}

void SuspendACurs(void)
{
	showACurs=false;
	HUnlock((Handle)(aCurs.frame[aCurs.currentFrame]));
}
			
#endif


/****************************************************************************
**
** 	initialisation funcitons
*/
void InitEditor ()  /* BH: return type should be void */
{
	long response=0;
	long i;
	OSErr err;
	Str255 buffer;
	
	err=Gestalt(gestaltSystemVersion,&response);
	response&=0xFFFF;
	if(err!=noErr || response<0x700) {
		SysBeep(7);
		doMessage(15);
		ExitToShell ();
	}
	err=Gestalt(gestaltProcessorType,&response);
	if(err!=noErr || response<gestalt68020) {
		SysBeep(7);
		doMessage(19);
		ExitToShell ();
	}
#if !TARGET_API_MAC_CARBON
    InitGraf(&qd.thePort);
#endif
	InitFonts();
	FlushEvents(everyEvent,nullStopMask);
	InitWindows();
	InitMenus();
	TE32KInit();
	InitDialogs(0); /*BH: changed ResumeProcPtr(restartProc) to 0 */

#if BEACHBALL
	InitACurs(160);			/* Init the beachball cursor */
#endif
	InitCursor();
	MaxApplZone();
	
    MoreMasters();       

	/* check if WNE is implemented, according to Technical Note #158 */
	
	response=0;
	err=Gestalt(gestaltKeyboardType,&response);
	gMacPlusKBD=(err==noErr && response<=3);
	
	response=0;
	err=Gestalt(gestaltQuickdrawVersion,&response);
	gHasColorQD=(err==noErr && (response&0xFF00));
	
	err=Gestalt (gestaltDragMgrAttr, &response);
	gHasDrag = (err==noErr);

	err=Gestalt (gestaltTranslationAttr, &response);
	gHasTranslationMgr = (err==noErr && response & (1<<gestaltTranslationMgrExists));

	for (i=0;i<MAXWINDS;i++) {
		Documents[i].fValidDoc=false;  /*BH: replaced NULL by false */
	}
	
	gInBackground = false;
	gDAonTop = false;		
		
	ASSERT ((PTScratch = NewHandle(1024)) != NULL && MemError() == noErr);
		
	gEditorResRefNum = CurResFile();

	PenNormal();

	ASSERT((DeskMenu=GetMenu(DESK_ID)) != NULL);
	AppendResMenu(DeskMenu,'DRVR');
	InsertMenu(DeskMenu,0);
	ASSERT((FileMenu=GetMenu(FILE_ID)) != NULL);
	InsertMenu(FileMenu,0);
	ASSERT((EditMenu=GetMenu(EDIT_ID)) != NULL);
	InsertMenu(EditMenu,0);
	ASSERT((FindMenu=GetMenu(FIND_ID)) != NULL);
	InsertMenu(FindMenu,0);
#if MARKS
	ASSERT((MarkMenu=GetMenu(MARK_ID)) != NULL);
	InsertMenu(MarkMenu,0);
#endif
	ASSERT((WindowMenu=GetMenu(WINDOW_ID)) != NULL);
	InsertMenu(WindowMenu,0);
	err = HMGetHelpMenuHandle (&HelpMenu);
	if (err != noErr)
		HelpMenu = (MenuHandle) 0;
	if (HelpMenu) {
		for (i=1; i <= iLastInHelpMenuRel; i++) {
			GetIndString (buffer, HELP_ITEMS_ID, i);
			AppendMenu (HelpMenu, buffer);
		}
		gNumberSystemHelpItems = CountMItems(HelpMenu) - iLastInHelpMenuRel;
	}
	AdjustMenus((DocumentPtr)NULL, 0);
	DrawMenuBar();
	
	err = FSMakeFSSpec(0, 0,"\p",&DefaultSpecs);
	ASSERT (err == noErr || err == fnfErr);
	
	if(Gestalt(gestaltAppleEventsAttr,&response)==noErr) 
		InitAEStuff();	
		
	for (i=1;i<256;i++)
		gUppercaseTable[i]=(char)i;
	gUppercaseTable[0] = 255;
	UpperString (gUppercaseTable, false);
	gUppercaseTable[0] = 0;

	ASSERT ((DialogStandardFilterUPP = NewModalFilterProc(DialogStandardFilter)) != NULL);  
	ASSERT ((SimpleDialogFilterUPP = NewModalFilterProc(SimpleDialogFilter)) != NULL);   
	ASSERT ((formatFilterUPP = NewModalFilterProc (formatFilter)) != NULL);
	ASSERT ((myControlActionUPP = NewControlActionProc (myControlActionProc)) != NULL); 	
	
    ASSERT ((doLineUPP = NewUserItemProc (doLine)) != NULL);
    ASSERT ((doButtonUPP = NewUserItemProc (doButton)) != NULL);
    ASSERT ((doFrameUPP = NewUserItemProc (doFrame)) != NULL);
}	


/****************************************************************************
**
**  generic document functions
*/
DocumentPtr GetEmptyDocument()
{
	long i;
	DocumentPtr doc;
	char* p;
	long count;
	
	for(i=NUMRESERVEDWINDS;i<MAXWINDS;i++)   /*BH: skip windows reserved for console*/
		if(!Documents[i].fValidDoc) {
			doc=&Documents[i];
			count = sizeof (DocumentRecord);
			for (p = (char*)(Documents+i); count; count--)
				*p++ = '\0';
			AddDefaultDocumentMethods (Documents+i);
			return doc;
		}
	InitCursor();
	doMessage(4);	
	return 0;
}

static DocumentPtr FindDocument(WindowPtr wind)
{
	long i;
	
	if (wind)
		for(i=0;i<MAXWINDS;i++) {
			if(Documents[i].fValidDoc && wind == Documents[i].docWindow)  /*BH: (WindowPtr) inserted */
				return Documents+i;
		}
	return 0;
}

Boolean EqualFSSpec (FSSpec * spec1, FSSpec * spec2)
{
	return spec1->vRefNum==spec2->vRefNum
		&& spec1->parID==spec2->parID
		&& EqualString (spec1->name, spec2->name,false, true);
}


DocumentPtr FindDocumentFromFSSpec (FSSpec * theSpecs, OSType type)
{
	long i;
	DocumentPtr doc;
	
	for(i=0;i < MAXWINDS;i++) {
		doc=Documents+i;
		if(doc->fValidDoc && doc->fValidFSSpec 
				&& doc->fDocType==type && EqualFSSpec (&doc->fileSpecs, theSpecs))
			return doc;
	}
	return (DocumentPtr)NULL;
}


short CountDocuments ()
{
	long i, n;
	
	n = NUMRESERVEDWINDS;
	for(i=NUMRESERVEDWINDS;i<MAXWINDS;i++)
		if(Documents[i].fValidDoc)
			n++;
	return n;
}

	
#if STATE
unsigned long GetModDate(FSSpec *specs)
{
	HFileParam pB;
	long i;
	
	for (i = 0; i < sizeof(HFileParam); i++)
		((char*)&pB)[i] = '\0';
	pB.ioCompletion=0;
	pB.ioNamePtr=specs->name;
	pB.ioVRefNum=specs->vRefNum;
	pB.ioFDirIndex=0;
	pB.ioDirID=specs->parID;
		
	PBHGetFInfoSync((HParmBlkPtr)&pB);
	
	return pB.ioFlMdDat;
}


void SetModDate(FSSpec *specs, unsigned long modDate)
{
	OSErr err;
	HFileParam pB;
	long i;
	
	if(modDate) {
	
		for (i = 0; i < sizeof(HFileParam); i++)
			((char*)&pB)[i] = '\0';
		pB.ioCompletion=0;
		pB.ioNamePtr=specs->name;
		pB.ioVRefNum=specs->vRefNum;
		pB.ioFDirIndex=0;
		pB.ioDirID=specs->parID;
		
		err=PBHGetFInfoSync((HParmBlkPtr)&pB);
		
		pB.ioFlMdDat=modDate;
		pB.ioDirID=specs->parID;

		err=PBHSetFInfoSync((HParmBlkPtr)&pB);
	}
}
#endif



static void CloseDocFile(DocumentPtr doc)
{
	OSErr err;
	long res;
	unsigned long modDate;
	
	if (doc->dataPathRefNum)
		if (err = FSClose(doc->dataPathRefNum))
			doDiagnosticMessage (22, err);
		else {
			doc->dataPathRefNum=0;
		}

#if STATE || MARKS
	if (res = doc->resourcePathRefNum) {
#if STATE
			if(doc->windowState) 
				modDate = (*doc->windowState)->modifiedDate;
#endif

# if ASCONSOLE
		if(res != gEditorResRefNum && res != gPreferencesResRefNum) 
# else
		if(res != gEditorResRefNum) /* if this is not a special resource */
# endif
		{
			CloseResFile(res); /* close resource file */
			doc->resourcePathRefNum=0;
# if MARKS
			doc->marks=0;
# endif
# if STATE
			if(doc->windowState) 
				SetModDate(&doc->fileSpecs, modDate);
			doc->windowState=0;
# endif		
		} else { /* otherwise just release the resources */
# if MARKS
			if(doc->marks)
				ReleaseResource (doc->marks);
			doc->marks=0;
# endif
# if STATE
			if(doc->windowState) {
				SetModDate(&doc->fileSpecs, modDate);
				ReleaseResource ((Handle) doc->windowState);
			}
			doc->windowState=0;
# endif		
			
		}
	}
#endif
}

void SetDocWindowTitle (DocumentPtr doc,Str255 title)
{
	if( doc->docWindow) 
		SetWTitle(doc->docWindow,title);
}

static void GetDocWindowTitle (DocumentPtr doc,Str255 title)
{
	if( doc->docWindow) 
		GetWTitle(doc->docWindow, title);
}

void ShowDocWindow (DocumentPtr doc)
{
	if( doc->docWindow) 
		ShowWindow (doc->docWindow);
}

void SizeScrollBars (DocumentPtr doc)
{
	Rect r, cr;
	
	METHOD_FocusOnDocument(doc);
	GetWindowPortBounds (doc->docWindow, &r);
	if(doc->vScroll) {
		SizeControl(doc->vScroll, SCROLLBAR_WIDTH, r.bottom - r.top - SCROLLBAR_WIDTH + 3);
		MoveControl(doc->vScroll, r.right - SCROLLBAR_WIDTH + 1,-1);
#if TARGET_CPU_PPC
		GetControlBounds (doc->vScroll, &cr);
		ValidRect(&cr);
#else
		ValidRect(&(**doc->vScroll).contrlRect);
#endif
	}
 	if(doc->hScroll) {
		SizeControl(doc->hScroll, r.right - r.left - SCROLLBAR_WIDTH + 3,SCROLLBAR_WIDTH);
		MoveControl(doc->hScroll, -1 ,r.bottom - r.top - SCROLLBAR_WIDTH + 1);
#if TARGET_CPU_PPC
		GetControlBounds (doc->hScroll, &cr);
		ValidRect(&cr);
#else
		ValidRect(&(**doc->hScroll).contrlRect);
#endif
	}
}


static short WantToSave (DocumentPtr doc, Boolean canCancel)  /* BH: inserted canCancel */
{
	Str255 title;
	Str255 nullStr;
	
	*nullStr=0;
	
	if( doc->docWindow) {
		GetWTitle(doc->docWindow,title);
		ParamText(title,nullStr,nullStr,nullStr);
	} else
		ParamText(nullStr,nullStr,nullStr,nullStr);
	
	GetUserAttention ();

	if (canCancel)
		return Alert(500,(ModalFilterUPP)0);
	else
		return Alert(501,(ModalFilterUPP)0);
}


/****************************************************************************
**
**  event handlers
*/
static void DoActivate(EventRecord *EvtPtr)           
{
	WindowPtr targetWindow;
    DocumentPtr doc;
    
	targetWindow=(WindowPtr)EvtPtr->message; 		/* What window is it in?  */
	
	if(doc = FindDocument(targetWindow)) 			/* Is it a Documents window? */
		if (EvtPtr->modifiers & activeFlag)
			METHOD_Activate(doc);
		else
			METHOD_Deactivate(doc);
}

	
Boolean DoSaveAs (DocumentPtr doc)
{
	StandardFileReply reply;
	long response=0;
#if STATE
	unsigned long modDate=0;
#endif
#if STATE || MARKS
	short resourcePathRefNum=0;
#endif
	short dataPathRefNum=0;
	OSErr err;
	FSSpec existingFileInfo;
	Boolean existingFileReadOnly;
	Str255 buf;
		
	GetIndString(buf,131,4);
	StandardPutFile(buf,doc->fileSpecs.name,&reply);
	
	if(!reply.sfGood)	/* the user canceled SaveAs dialog*/
		return false;

	existingFileReadOnly = doc->fReadOnly;
	
	if(dataPathRefNum=doc->dataPathRefNum) {
		existingFileInfo=doc->fileSpecs;
#if MARKS || STATE
		resourcePathRefNum=doc->resourcePathRefNum;
# if STATE
		if(doc->windowState)
			modDate = (*doc->windowState)->modifiedDate;
# endif
#endif
	}

	doc->fileSpecs=reply.sfFile;
	doc->fReadOnly = false;
	
	if(!METHOD_OpenDocFile(doc))	{		/* file didn't open */
		doc->fileSpecs=existingFileInfo;
		return false;
	}
	
	if(!METHOD_WriteDocFile(doc)) {		/* write was unsuccessful */
		if (existingFileReadOnly && !doc->fReadOnly) {
			doc->fReadOnly = existingFileReadOnly;
			AddTextReadOnlyMethods (doc);
			AdjustMenus(doc, 0);
		}
		doc->fileSpecs=existingFileInfo;
#if STATE || MARKS
		doc->resourcePathRefNum=resourcePathRefNum;
#endif
		doc->dataPathRefNum=dataPathRefNum;
		return false;
	}

#if STATE || MARKS
	if(resourcePathRefNum && doc->resourcePathRefNum) {
		UseResFile(doc->resourcePathRefNum);
#if STATE
		if(doc->windowState) {
			DetachResource((Handle)doc->windowState);
			AddResource((Handle)doc->windowState,'MPSR',1005,"\p");  /*BH: last string must be Pascal */
			WriteResource((Handle)doc->windowState);
		}
#endif
#if MARKS
		if(doc->marks) {
			DetachResource(doc->marks);
			AddResource(doc->marks,'MPSR',1007,"\p");  /*BH: last string must be Pascal */
			WriteResource(doc->marks);
		}
#endif	
	}
#endif
	
	
	doc->fValidFSSpec=true;
	doc->fNeedToSave=false;
	SetDocWindowTitle(doc,reply.sfFile.name);
	
	if(dataPathRefNum) {
		err = FSClose(dataPathRefNum);
#if STATE || MARKS
		if(resourcePathRefNum)
			CloseResFile(resourcePathRefNum);
#if STATE
		if(modDate) 
			SetModDate(&existingFileInfo,modDate);
#endif
#endif
	}
	return true;
}

static Boolean DoSaveACopy (DocumentPtr doc)
{
	StandardFileReply reply;
	FSSpec existingFileInfo;
	long response=0;
#if STATE || MARKS
	short resourcePathRefNum=0;
	Handle res;
	OSErr err;
#endif
	short dataPathRefNum=0;
	Boolean fReadOnly=0;
	Boolean ret=false;
#if STATE
	MPSRWindowResource** windowState;
#endif
#if MARKS
	Handle marks;
#endif
	
	void (* existingDoKeyDown) (DocumentPtr, EventRecord *);
	Boolean (* existingConvertKey) (DocumentPtr, EventRecord *);
	Boolean (* existingWriteDocFile) (DocumentPtr);
	void (* existingAdjustDocMenus) (DocumentPtr, short);

	Str255 buf;
	
	GetIndString(buf,131,5);
	StandardPutFile(buf,doc->fileSpecs.name,&reply);
	
	if(!reply.sfGood) 
		return false;
		
	existingFileInfo=doc->fileSpecs;
	dataPathRefNum=doc->dataPathRefNum;
	
#if STATE || MARKS
	resourcePathRefNum=doc->resourcePathRefNum;
#endif

	fReadOnly=doc->fReadOnly;
	
#if MARKS
	marks=doc->marks;
#endif

#if STATE
	windowState=doc->windowState;
#endif
	
	existingDoKeyDown=doc->mDoKeyDown;
	existingConvertKey=doc->mConvertKey;
	existingWriteDocFile=doc->mWriteDocFile;
	existingAdjustDocMenus=doc->mAdjustDocMenus;

#if STATE || MARKS
	doc->resourcePathRefNum=0;
#endif

	doc->dataPathRefNum=0;
	doc->fReadOnly=0;

	/* 	doc->marks has been removed as a resource. We need a copy of its
		data for the new file. The copy will become a resource and be
		purged from memory. The orginal (**marks) is still good. */
			
	doc->fileSpecs=reply.sfFile;

	if(METHOD_OpenDocFile(doc)) {	
#if STATE || MARKS
		if(resourcePathRefNum && doc->resourcePathRefNum) {	/* do both the original and new file have a resource fork? */

			UseResFile(doc->resourcePathRefNum);
			
#if STATE
			if(res=(Handle)windowState) {
				err=HandToHand(&res);
				if(err==noErr) {
					doc->windowState=(MPSRWindowResource**)res;
					AddResource(res,'MPSR',1005,"\p");  /*BH: last string must be Pascal */
				} else
					doc->windowState=0;
			}
#endif
#if MARKS
			if(res=marks) {
				err=HandToHand(&res);
				if(err==noErr) {
					doc->marks=res;
					AddResource(doc->marks,'MPSR',1007,"\p");  /*BH: last string must be Pascal */
				} else
					doc->marks=0;
			}
#endif
		}
#endif
		ret=METHOD_WriteDocFile(doc);
		CloseDocFile(doc);
	}
			
	doc->fileSpecs=existingFileInfo;
	doc->dataPathRefNum=dataPathRefNum;

#if MARKS
	doc->marks=marks;
#endif

#if STATE
	doc->windowState=windowState;
#endif

#if STATE || MARKS
	doc->resourcePathRefNum=resourcePathRefNum;
#endif

	doc->fReadOnly=fReadOnly; 
	
	doc->mDoKeyDown=existingDoKeyDown;
	doc->mConvertKey=existingConvertKey;
	doc->mWriteDocFile=existingWriteDocFile;
	doc->mAdjustDocMenus=existingAdjustDocMenus;

	return ret;
}


static Boolean DoSave (DocumentPtr doc)
{
	
	if(!doc->fValidFSSpec) 
		return DoSaveAs(doc);
		
	if(METHOD_WriteDocFile(doc)) {
		doc->fNeedToSave=false;
		return true;
	} else
		return false;
}

Boolean DoClose (DocumentPtr doc, Boolean canCancel)    /*BH: canCancel inserted */
{
	short saveit;
	Rect r;
	Boolean res;
#if TARGET_CPU_PPC
	RgnHandle visRgn;
#endif
	GrafPtr thePort;
		
#if GAPVER ==3 || GAPVER == 4	
	LOGDOCUMENT.fNeedToSave = false;
# if HELP_WINDOW
	HELPDOCUMENT.fNeedToSave = false;
# endif
#endif

	if (!doc->fValidDoc)
		return true;
		
#ifdef GAPVER
	if (doc==&LOGDOCUMENT) {
		DoClearLog (doc);
		return true;
	}
	
	if (!TE32KIsEOF (doc->docData) && canCancel) { /* don't close document if GAP is reading from it */
		doMessage (20);
		return false;
	}
#endif

	if( doc->fNeedToSave) {
		if( doc->docWindow) {
			SelectWindow (doc->docWindow);
			/* now aactivate and update manually */
			METHOD_Activate(doc);
			METHOD_FocusOnContent(doc);
#if TARGET_CPU_PPC
			visRgn = NewRgn();
			thePort = (GrafPtr)GetWindowPort (doc->docWindow);
			GetPortVisibleRegion (thePort, visRgn);					
			GetRegionBounds (visRgn, &r);
			DisposeRgn (visRgn);
#else
			r=(**(doc->docWindow->visRgn)).rgnBBox;
#endif
			METHOD_Draw(doc,&r,0);
			METHOD_FocusOnDocument(doc);
			DrawControls(doc->docWindow);
			DrawGrowIcon(doc->docWindow);
		}
		saveit = WantToSave(doc, canCancel);  
		if(saveit == iCancel)
			return false;
		if(saveit == iYes) {
			if(!DoSave(doc)) {
				doMessage (6);
				return false;
			}
		}
	}
#if MARK || STATE
	METHOD_WriteDocResourceFork(doc);
#endif

	/*	close the file	*/
	CloseDocFile (doc);
	res = METHOD_Destructor(doc);
	doc = FindDocument (FrontWindow());
	AdjustMenus(doc, 0);
	return res;
}

static Boolean DoRevert (DocumentPtr doc)
{
	Rect box;
#if MARKS
	Handle mH;
	OSErr err;
#endif
	
	if(doConfirmDialog(6,doc->fileSpecs.name)) {
#if MARKS
		if(doc->marks) {
			DetachResource(doc->marks);
			DisposeHandle(doc->marks);
			doc->marks=0;
		}
#endif
#if STATE
		if(doc->windowState) {
			DetachResource((Handle)doc->windowState);
			DisposeHandle((Handle)doc->windowState);
			doc->windowState=0;
		}
#endif
		if(METHOD_ReadDocFile(doc)) {
			SetPortWindowPort (doc->docWindow);
			METHOD_GetContentRect(doc,&box);
			InvalRect(&box);
			EraseRect(&box);
#if MARKS
			if(doc->marks)
				FillMarkMenu(doc);
			else {
				if (doc->resRefNum) {
					UseResFile (doc->resRefNum);
					mH=Get1Resource('MENU',MARK_ID);
					err=HandToHand(&mH);
					if(err==noErr)
						doc->markMenu=(MenuHandle)mH;
					else
						doc->markMenu=0;
				}
			}
#endif
			doc->fNeedToSave=false;
			return true;
		}
	} 
	return false;
}


/****************************************************************************
**
** 	DoMenu processes menu related mouse events
*/
static void DoMenu (DocumentPtr doc, long menuResult,short modifiers)  /* BH: return value should be void */
{
	short menuID,itemNumber;
#if MARK
	short itemMark;
#endif
	Str255 buf;
	GrafPtr theCurrentPort;
#ifdef GAPVER
	EventRecord theEvent;
    TE32KHandle tH;
#endif
	
	menuID=HiWord(menuResult);
	itemNumber=LoWord(menuResult);
	InitCursor();
	
	/* Give current doc a chance to handle the item. */
	if(doc && METHOD_DoDocMenuCommand(doc,menuID,itemNumber,modifiers)) {
		return;
	}
	
	switch(menuID) {
		case DESK_ID:
			if (itemNumber==1) 
				OpenAboutBox (0);
			else if (itemNumber==0) 	/* nested menus */
				;
			else {						/* a desk accessory */
				GetMenuItemText(DeskMenu,(short) itemNumber,buf); /*BH: (short) inserted, GetItem -> GetMenuItemText*/
				GetPort(&theCurrentPort);
				OpenDeskAcc(buf);       /*BH: &daname -> daname*/
				SetPort(theCurrentPort);
			}
			break;
		case FILE_ID:	/* the file menu */
			switch(itemNumber) {
				case iNew:
					OpenNewDoc();
					break;
				case iOpen:
					OpenExistingFileDialog((modifiers&optionKey) != 0);
				    break;
				case iClose:
					if (doc) 
						DoClose(doc, true);
					break;
				case iRead:
					if (doc) {
						if (!METHOD_ReadIntoGAP (doc, 
								(modifiers&optionKey) != 0, (modifiers&shiftKey) != 0))
							SysBeep (4);
						else
							SelectWindow (LOGDOCUMENT.docWindow);
					}
					break;
				case iLogTo:
					DoLogTo ();
					break;
				case iStop:
					SelectWindow (LOGDOCUMENT.docWindow);
					SyIsInterrupted = 1;
					break;
				case iSave:
					if(doc)
						DoSave(doc);
					break;
				case iSaveAs:
					if(doc)
						DoSaveAs(doc);
					break;
				case iSaveACopy:
					if(doc)
						DoSaveACopy(doc);
					break;
				case iRevert:
					if(doc)
						DoRevert(doc);
					break;
				case iPageSetup:
					if(doc)
						METHOD_DoPageSetup(doc);
					break;
				case iPrint:
					if(doc)
						METHOD_DoPrint(doc);
					break;
				case iQuit:
					DoQuit(true);
					break;
				default:
					break;
			}
			break;
		case EDIT_ID:	/* the edit menu */
			switch(itemNumber) {
				case iUndo:
					METHOD_DoUndo(doc);
					break;
				case iCut:
					METHOD_DoCut(doc);
					break;
				case iCopy:
					METHOD_DoCopy(doc);
					break;
				case iPaste:
					METHOD_DoPaste(doc);
					break;
				case iClear:
					METHOD_DoClear(doc);
					break;
				case iSelectAll:
					METHOD_DoSelectAll(doc);
					break;
				case iShowClipboard:
					if(gClipboardDoc) 
						DoClose(gClipboardDoc, true);
					else 
						gClipboardDoc=OpenClipboardWindow();
					break;
#if PREFERENCES
				case iPreferences:
					GetOptions (false);
					break;
#endif
				default:
					break;
			}
			break;
/*		case FIND_ID:		the Find menu is handled by the document methods */
#if MARKS
		case MARK_ID:
			if(itemNumber==iAlphabetical) {	
				GetItemMark(MarkMenu,iAlphabetical,&itemMark);
				sortMarks( doc,(Boolean)itemMark);
			} 
			break;
#endif
		case WINDOW_ID:
			switch (itemNumber) {
				case iTileWindows:
					TileWindows();
					break;
				case iStackWindows:
					StackWindows();
					break;
				case iShowGarbageCollect:
#if GAPVER == 4
					if (SyMsgsFlagBags)
						SyMsgsFlagBags = 0;
					else
          				if (gShowPartialCollection)
          					SyMsgsFlagBags = 2;
          				else
          					SyMsgsFlagBags = 1;
#elif GAPVER == 3
					SyGasman = 1 - SyGasman;
#endif
					break;
#if GAPVER == 4
				case iShowPartial:
					gShowPartialCollection = !gShowPartialCollection;
					if (SyMsgsFlagBags)
          				if (gShowPartialCollection)
          					SyMsgsFlagBags = 2;
          				else
          					SyMsgsFlagBags = 1;
          			break;
#endif
				case iScrollLog:
					gScrollToPrintout = !gScrollToPrintout;
					if (gScrollToPrintout && (tH=LOGDOCUMENT.docData)) {
						TE32KSetSelect ((**tH).consolePos, (**tH).consolePos, tH);
						TE32KSelView (LOGDOCUMENT.docData);
						METHOD_AdjustScrollBars (&LOGDOCUMENT);
					}
					break;
				default:
					WindowMenuSelect(itemNumber-iLastWindowMenuItem);
					break;
			}
			break;
#ifdef GAPVER
		case kHMHelpMenuID:
			switch (itemNumber-gNumberSystemHelpItems) {
				case iHelpSelectionRel:
					if (doc && GetSelection (doc, (char*) buf, 255)) {
						GET_GAP_HELP ((char*) buf);
					}
					else 
						GET_GAP_HELP ("");
					break;
				case iFindIndexRel:
					if (doc && GetSelection (doc, (char*)buf+1, 254)) {
						buf[0] = '?'; 
						GET_GAP_HELP ((char*) buf);
					}
					else 
						SysBeep (2);
					break;
				case iShowCompletionsRel:
					if (doc && (tH= doc->docData) && (**tH).selStart<(**tH).selEnd) {
						theEvent.what = keyDown;
						theEvent.message = TAB;
						theEvent.modifiers = controlKey | shiftKey;
						DoKey (&theEvent);
					}
					else
						SysBeep (2);
					break;
				case iPrecSectionRel:	
					GET_GAP_HELP ("<");
					break;
				case iNextSectionRel:
					GET_GAP_HELP (">");
					break;
				case iPrevChapterRel:
					GET_GAP_HELP ("<<");
					break;
				case iNextChapterRel:
					GET_GAP_HELP (">>");
					break;
				case iHelpHelpRel:
#if GAPVER == 3
					GET_GAP_HELP ("Help");
#elif GAPVER == 4
					GET_GAP_HELP ("tutorial:The Help system");
#endif
					break;
				case iIntroductionRel:
#if GAPVER == 3 
					GET_GAP_HELP ("About GAP");
#elif GAPVER == 4
					GET_GAP_HELP ("Welcome to GAP");
#endif
					break;
#if GAPVER == 4
				case iMacGAPRel:
					GET_GAP_HELP ("reference:GAP for MacOS");
					break;
#endif
				default: /* this is a file from the history or one of the standard chapters */
					if (HelpMenu) {
						GetMenuItemText (HelpMenu, itemNumber, buf); /* changed GetItem to GetMenuItemText */
						if (buf[0] < 255)
							buf[buf[0]+1] = '\0';
						else
							buf[255] = '\0';
						GET_GAP_HELP ((char*)buf+1);
					}
					break;
			}
#endif
	}	
	return;
}

/****************************************************************************
**
** 	called when GAP quits, canCancel is false when a GAP error (e.g. out of 
**  memory error) has occured, in this case the user has to save or discard
**  all documents
*/

void DoQuit(Boolean canCancel)  /*BH: canCancel inserted */
{
	long i;

#ifdef GAPVER
	if (canCancel) {
		GetUserAttention ();
		if (CautionAlert(502,(ModalFilterUPP)0) != iYes)
			return;
	}
	LOGDOCUMENT.fNeedToSave = false;
 #if HELP_WINDOW
	HELPDOCUMENT.fNeedToSave = false;
# endif
#endif


	for(i=MAXWINDS-1;i>=0;i--) {
		if (Documents[i].fValidDoc) {
			if (!canCancel)
				TE32KSetEOF (Documents[i].docData);
			if(!DoClose(&Documents[i], false)) {
				if (canCancel)
					return;		/* Couldn't close a doc. Abort Quit if possible. */
			}
		Documents[i].fValidDoc = false;
		}
	}
	
	/* DoClose does not close log window, so we must save its settings */
	METHOD_WriteDocResourceFork (&LOGDOCUMENT); 
	
#ifdef GAPVER

#if GAPVER == 3
	if (!gUserWantsToQuitGAP)
#else
	if (!SyInitializing && !gUserWantsToQuitGAP) 
#endif
	{
		gUserWantsToQuitGAP = true;	/* signal EOF of console to GAP */
		if (!gGAPIsIdle)
			SyIsInterrupted = 1; /* try to interrupt GAP, so that it can recognise EOF on console */
		return;
	}
	gUserWantsToQuitGAP = true;	/* signal EOF of console to GAP */
	SyExit (0); /* only call SyExit directly if initializing or the other method failed */
#endif
			
	ExitToShell ();
}


	
	
/****************************************************************************
**
** 	main event loop
*/

void * lowestStack = (void*)-1;
void * highestStack = (void*) 0;

void ProcessEvent ()
{
	EventRecord theEvent;
	long idleTime;
	DocumentPtr doc;
	void * p;
	
	p = (void*) &theEvent;
	if (p < lowestStack)
		lowestStack = p;
		
	if (p > highestStack)
		highestStack = p;
		
	
	if (gGAPIsIdle) {
		if (gInBackground) 
			idleTime = -1;  /* don't need null events while running in the background */
		else 
			idleTime = GetCaretTime(); /* need null events to blink text cursor */
	}
	else {
		idleTime = 0;  /* get as much time as possible for calculations */
#if GAPVER == 3 || GAPVER == 4
 		if (LOGDOCUMENT.fValidDoc && LOGDOCUMENT.fNeedToSave) { /* check if input line has changed */
			consoleHistoryPtr = consoleHistory-1;  /* reset history */
			LOGDOCUMENT.fNeedToSave = false; /* may still be true if called from SyIsIntr() */
			/* note that browsing in history does not change LOGDOCUMENT.fNeedToSave */
		}
#endif
	}
	
	if(WaitNextEvent(everyEvent, &theEvent, idleTime, NULL)) {
		switch(theEvent.what) {
			case osEvt:
				OSEvent(&theEvent);
				break;
			case mouseDown:
				DoMouse(&theEvent);
				break;
			case keyDown:
			case autoKey:
				DoKey(&theEvent);
				break;
			case activateEvt:
				DoActivate(&theEvent);
				break;
			case updateEvt:
				doc = FindDocument ((WindowPtr)(theEvent.message)); 
				DoUpdate (doc);
				break;
			case kHighLevelEvent:
                DoHighLevel(&theEvent);
			default:
				break;
		}
	} else {
		doc = FindDocument(FrontWindow());
		if (doc)
			METHOD_DoIdle (doc);
	}
}

static void DoHighLevel(EventRecord *AERecord)
{
	OSErr myErr;
    myErr=AEProcessAppleEvent(AERecord);
}

void DoUpdate (DocumentPtr doc)
{
	Rect r;
	GrafPtr thePort;
#if TARGET_CPU_PPC
	RgnHandle visRgn;
#endif
	
	if(doc && doc->fValidDoc) {
		METHOD_FocusOnContent(doc);
		BeginUpdate(doc->docWindow);
		thePort = (GrafPtr)GetWindowPort (doc->docWindow);
#if TARGET_CPU_PPC
		visRgn = NewRgn();
		GetPortVisibleRegion (thePort, visRgn);	
		GetRegionBounds (visRgn, &r);
		DisposeRgn (visRgn);
#else
		r=(**(doc->docWindow->visRgn)).rgnBBox;
#endif
		METHOD_Draw(doc,&r,0);
		METHOD_FocusOnDocument(doc);
		DrawControls(doc->docWindow);
		if (!doc->fNoGrow)
			DrawGrowIcon(doc->docWindow);
		EndUpdate(doc->docWindow);
	}
}


static Boolean isEditKey(EventRecord *theEvent)
{
	char keyCode,ch;
	
/*	This routine returns true if the key is an arrow key. */

	if(gMacPlusKBD) {
		switch(keyCode = (short)(theEvent->message&keyCodeMask)>>8) {
			case 0x42:
				theEvent->message=(theEvent->message&~charCodeMask)|RIGHTARROW;
				break;
			case 0x46:
				theEvent->message=(theEvent->message&~charCodeMask)|LEFTARROW;
				break;
			case 0x48:
				theEvent->message=(theEvent->message&~charCodeMask)|DOWNARROW;
				break;
			case 0x4D:
				theEvent->message=(theEvent->message&~charCodeMask)|UPARROW;
				break;
			default:
				break;
		}
	}
	ch=theEvent->message&charCodeMask;
	return ch==LEFTARROW || ch==RIGHTARROW || ch==DOWNARROW || ch==UPARROW;
}



static void DoKey(EventRecord *theEvent)
{
	long ch;
	TE32KHandle tH;
	long newLine;
	DocumentPtr doc;
	WindowPtr wind;
/*
	TE32K recognizes these char codes (decimal):
		LeftArrow 	28 
		RightArrow 	29
		UpArrow 	30
		DownArrow 	31
	MacPlus Keyboard virtual codes are (hex):
		LeftArrow 	46
		RightArrow 	42
		UpArrow 	4D
		DownArrow 	48
	MacII codes are:
		LeftArrow 	7B
		RightArrow 	7C
		UpArrow 	7E
		DownArrow 	7D
	Extended codes are:
		63	copy			10 (DLE)
		72	help/insert		05 (ENQ)
		73	home			01 (SOH)
		74	pg up			0B (VT)
		75	del fwrd		7F (DEL)
		76	paste			10
		77	end				04 (EOT)
		78	cut				10
		79	pg down			0C (FF)
		7A	undo			10
*/
	wind = FrontWindow();
	
	if (!(doc=FindDocument (wind))) 
		return;
	if (METHOD_DoConvertKey (doc, theEvent)) {
		/* key has been handled, just update controls */
		if (tH = doc->docData) {
			TE32KSelView(tH);
			METHOD_AdjustScrollBars(doc);
			doc->fHaveSelection = SetSelectionFlag(tH);
		}
		return;                
	}
	if (theEvent->modifiers&cmdKey) {
		AdjustMenus(doc, theEvent->modifiers);	/* Have to adjust before calling MenuKey */
		ch=MenuKey((short)theEvent->message&charCodeMask);
		if(ch&0xFFFF0000) {	/* There is an enabled menu item for this command-key equivalent. */
			DoMenu(doc, ch, theEvent->modifiers);
			while(TickCount() < theEvent->when+6) ;
			HiliteMenu(0);
			return;
		} else if(!isEditKey(theEvent))	{/* only cmd-arrow keys get further processing */
			SysBeep (4);
			return;
		}
	}
	/* The cut, copy, paste, and undo keys are processed here. */

	if((ch=theEvent->message&charCodeMask) == 0x10) {   /* function keys */
		switch (theEvent->message&keyCodeMask) {
			case 0x6300:
				if(doc->fHaveSelection) {
					FlashMenuBar(EDIT_ID);
					METHOD_DoCopy(doc);
					while (TickCount() < theEvent->when + GetDblTime())
						;
					FlashMenuBar(EDIT_ID);
				}
				return;
			case 0x7600:
				FlashMenuBar(EDIT_ID);
				METHOD_DoPaste(doc);
				while (TickCount() < theEvent->when + GetDblTime())
					;
				FlashMenuBar(EDIT_ID);
				return;
			case 0x7800:
				if(doc->fHaveSelection) {
					FlashMenuBar(EDIT_ID);
					METHOD_DoCut(doc);
					while (TickCount() < theEvent->when + GetDblTime())
						;
					FlashMenuBar(EDIT_ID);
				}
				return;
			case 0x7A00:
				if(doc->fNeedToSave) {
					FlashMenuBar(EDIT_ID);
					METHOD_DoUndo(doc);
					while (TickCount() < theEvent->when + GetDblTime())
						;
					FlashMenuBar(EDIT_ID);
				}
				return;
			default:
				break;
		}
	}
	if (doc && (tH = doc->docData)) {
	/* if neither option nor cmd key is pressed, just move the window, not the cursor */
		if (!(theEvent->modifiers&(optionKey|cmdKey))) {
			if (ch==HOME)							
				Scroll(doc, doc->vScroll,-kMaxShort);
			else if (ch==END)	
				Scroll(doc, doc->vScroll,kMaxShort);
			else if (ch==PAGEUP) 		
				DoPageScroll(doc, doc->vScroll,-kControlPageUpPart); /*BH: replaced inPageUp by kControlPageUpPart */
			else if (ch==PAGEDOWN)	
				DoPageScroll(doc, doc->vScroll,-kControlPageDownPart); /*BH: replaced inPageDown by kControlPageUpPart */
			else 
				METHOD_DoKeyDown(doc,theEvent);
		} else { /* if option or cmd key is pressed, move the window and the cursor */
			if ((ch==HOME) || (ch==UPARROW && theEvent->modifiers&cmdKey))	{	/*BH: inserted option- and command- UP-/DOWNARROW equivalents */
				TE32KSetSelect (0, 0, tH);
				doc->fHaveSelection = 0;
				TE32KSelView (tH);
				METHOD_AdjustScrollBars(doc); /* BH : inserted because METHOD_SetScrollBarValues disabled */
			}
			else if ((ch==END) || (ch==DOWNARROW && theEvent->modifiers&cmdKey))	{ 	/* end */
				TE32KSetSelect ((**tH).teLength, (**tH).teLength, tH);
				doc->fHaveSelection = 0;
				TE32KSelView (tH);
				METHOD_AdjustScrollBars(doc); /* BH : inserted because METHOD_SetScrollBarValues disabled */
			}
			else if ((ch==PAGEUP)  || (ch==UPARROW && (theEvent->modifiers&(optionKey|cmdKey))) ) {	   /* Page up */
				if (tH) {
					newLine = indexToLine ((**tH).selStart, tH) - METHOD_GetVertPageScrollAmount(doc);
					if (newLine < 0) 
						newLine = 0;
					TE32KSetSelect ((**tH).lineStarts[newLine], (**tH).lineStarts[newLine], tH);
					doc->fHaveSelection = 0;
					TE32KSelView (tH);
					METHOD_AdjustScrollBars(doc); /* BH : inserted because METHOD_SetScrollBarValues disabled */
				}
			}
			else if ((ch==PAGEDOWN)  || (ch==DOWNARROW && (theEvent->modifiers&(optionKey|cmdKey)))) {	  	/* Page down */
				if (tH) {
					newLine = indexToLine ((**tH).selStart, tH) + METHOD_GetVertPageScrollAmount(doc);
					if (newLine >= (**tH).nLines) 
						TE32KSetSelect ((**tH).teLength, (**tH).teLength, tH);
					else
						TE32KSetSelect ((**tH).lineStarts[newLine], (**tH).lineStarts[newLine], tH);
					doc->fHaveSelection = 0;
					TE32KSelView (tH);
					METHOD_AdjustScrollBars(doc); /* BH : inserted because METHOD_SetScrollBarValues disabled */
				}
			}
			else 
				METHOD_DoKeyDown(doc,theEvent);
		}
		
	}
}

static void ClearVariableMenu(MenuHandle menuH, short topItem)
{
	short i;
	
	for(i=CountMItems(menuH);i>topItem;i--)
		DeleteMenuItem(menuH,i);
}

/* 	BH: there should actually be a function AdjustMenuBar which enables/disables 
	the entire menu, because it is too late when AdjustMenus is called */
	
void AdjustMenus(DocumentPtr doc, short modifiers)
{
	long i;
	short item;
	Str255 itemText;
#if GAPVER == 3
	char * p, *q;
#endif

	ClearVariableMenu(WindowMenu,iLastWindowMenuItem);

#if GAPVER == 4
	CheckItem (WindowMenu, iShowGarbageCollect, SyMsgsFlagBags > 0);
	if (SyMsgsFlagBags == 2)
		gShowPartialCollection = true;
	CheckItem (WindowMenu, iShowPartial, gShowPartialCollection);
	SETMENUABILITY (WindowMenu, iShowPartial, SyMsgsFlagBags > 0);
#elif GAPVER == 3
	CheckItem (WindowMenu, iShowGarbageCollect, SyGasman > 0);
#endif

	CheckItem (WindowMenu, iScrollLog,  gScrollToPrintout);
	
#if GAPVER == 3 || GAPVER == 4
		SETMENUABILITY (FileMenu, iStop, !gGAPIsIdle);
#endif

	
	for(i=0; i<MAXWINDS; i++) {
		if(Documents[i].fValidDoc && Documents[i].docWindow) {
			if(GetWindowKind (Documents[i].docWindow)!=10) {	/* Don't bother with panes */
				AppendMenu (WindowMenu, "\pdummy");    
			    item = CountMItems (WindowMenu);   /* find its number */
				GetWTitle((Documents[i].docWindow),itemText);     /* get window title */
				SetMenuItemText (WindowMenu, item, itemText);/* make it name of item */
				if (i <= 9)
					SetItemCmd (WindowMenu, item, '0'+i);
				if(doc == Documents+i)  
					CheckItem (WindowMenu, item, true);
				if(Documents[i].fNeedToSave) 
					SetItemStyle (WindowMenu, item ,underline);   /* this is not what Apple says... */
			}
		}
	}
	
	if(doc) {
#if MARKS
		if(doc->marks) {
			EnableItem(MarkMenu,iMark);
			EnableItem(MarkMenu,iUnmark);
			EnableItem(MarkMenu,iAlphabetical);
		} else {
			EnableItem(MarkMenu,iMark);
			DisableItem(MarkMenu,iUnmark);
			DisableItem(MarkMenu,iAlphabetical);
		}
		EnableItem(MarkMenu,0);
#endif
		METHOD_AdjustDocMenus(doc, modifiers);
	} else {
		DisableItem (FileMenu, iRead);
		DisableItem (FileMenu, iLogTo);
		DisableItem(FileMenu,iClose);
		DisableItem(FileMenu,iSave);
		DisableItem(FileMenu,iSaveAs);
		DisableItem(FileMenu,iRevert);
		DisableItem(FileMenu,iPageSetup);
		DisableItem(FileMenu,iPrint);
		DisableItem(FileMenu,iRead);
		DisableItem(FileMenu,iLogTo);
		DisableItem(EditMenu,iUndo);
		DisableItem(EditMenu,iCut);
		DisableItem(EditMenu,iCopy);
		DisableItem(EditMenu,iPaste);
		DisableItem(EditMenu,iClear);
		DisableItem(EditMenu,iSelectAll);
		DisableItem(EditMenu,iFormat);
		DisableItem(EditMenu,iWrap);
		DisableItem(EditMenu,iAutoIndent);
		DisableItem(EditMenu,iAlign);
		DisableItem(EditMenu,iShiftRight);
		DisableItem(EditMenu,iShiftLeft);
		EnableItem(FileMenu,0);
		EnableItem(EditMenu,0);
		EnableItem(WindowMenu,0);

		DisableItem(FindMenu,0);
#if MARKS
		DisableItem(MarkMenu,0);
#endif
	}

#if PREFERENCES
	EnableItem (EditMenu, iPreferences);
#endif

	EnableItem(EditMenu, iShowClipboard);

#ifdef GAPVER
	if (HelpMenu) {
			
#if GAPVER == 3 /* show help history */
		ClearVariableMenu (HelpMenu, iLastInHelpMenuRel+gNumberSystemHelpItems);
		
		if ( syLastTopics[0][0])
			AppendMenu (HelpMenu, "\p(-");
			
		for (i = 0;  (i < LENHELPHISTORY) && syLastTopics[i][0]; i++) {
			p = syLastTopics[i]; 
			q = (char*)itemText + 1;
			while (*p != '\0') 
				*q++ = *p++;
			*itemText = q - (char*)itemText - 1;
			if (*itemText)
				AppendMenu (HelpMenu, itemText );
			else
				AppendMenu (HelpMenu, "\p(Internal Error)");
		}
#endif

#if GAPVER == 4 /* in GAP 3, Help is always available */
		if (gGAPIsIdle) {
#endif
			if (doc->fHaveSelection) {
				EnableItem (HelpMenu, iHelpSelectionRel + gNumberSystemHelpItems);
				EnableItem (HelpMenu,iFindIndexRel + gNumberSystemHelpItems);
				EnableItem (HelpMenu,iShowCompletionsRel + gNumberSystemHelpItems);
			} else {
				DisableItem (HelpMenu, iHelpSelectionRel + gNumberSystemHelpItems);
				DisableItem (HelpMenu,iFindIndexRel + gNumberSystemHelpItems);
				DisableItem (HelpMenu,iShowCompletionsRel + gNumberSystemHelpItems);
			}
			EnableItem (HelpMenu,  iPrecSectionRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,  iNextSectionRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,  iPrevChapterRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,  iNextChapterRel + gNumberSystemHelpItems);
#if GAPVER == 3
			EnableItem (HelpMenu,  iIntroductionRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,  iChaptersRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,  iCopyrightRel + gNumberSystemHelpItems);
#elif GAPVER == 4
			EnableItem (HelpMenu,   iBooksRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,   iChaptersRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,   iSectionsRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,   iCopyrightRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,   iAuthorsRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,   iIntroductionRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,   iMacGAPRel + gNumberSystemHelpItems);
			EnableItem (HelpMenu,   iHelpHelpRel + gNumberSystemHelpItems);
#endif
#if GAPVER == 4
		} else {
			DisableItem (HelpMenu, iHelpSelectionRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,iFindIndexRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,iShowCompletionsRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,  iPrecSectionRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,  iNextSectionRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,  iPrevChapterRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,  iNextChapterRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,   iBooksRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,   iChaptersRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,   iSectionsRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,   iCopyrightRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,   iIntroductionRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,   iAuthorsRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,   iMacGAPRel + gNumberSystemHelpItems);
			DisableItem (HelpMenu,   iHelpHelpRel + gNumberSystemHelpItems);
			for (	i = CountMItems (HelpMenu); 
					i > iLastInHelpMenuRel + gNumberSystemHelpItems;
					i--)
				DisableItem (HelpMenu, i);
		}
#endif
	}
#endif

	DrawMenuBar ();
}

static void DoMouse(EventRecord *theEvent)
{
	Point eventPt;
	short windowCode;
	WindowPtr wind;
	DocumentPtr doc;
	long growRes;
	RgnHandle grayRgn;
	Rect r;
	
	eventPt=theEvent->where;
	
	windowCode=FindWindow(eventPt,&wind);

	doc = FindDocument (wind);
	
	switch(windowCode) {
		case inSysWindow:
			SystemClick(theEvent,wind);
			break;
		case inMenuBar:
			doc = FindDocument (FrontWindow());
			if (doc) {
				AdjustMenus(doc, theEvent->modifiers);
				DoMenu(doc, MenuSelect(theEvent->where), theEvent->modifiers);
				HiliteMenu(0);
			}
			break;
		case inGoAway:
			if (doc && TrackGoAway(wind,theEvent->where)) 
				DoClose(doc, true);
			break;
		case inDrag:
			/* BH: changed region to GrayRgn for multiple monitors */
			grayRgn = GetGrayRgn();
#if TARGET_CPU_PPC
			GetRegionBounds (grayRgn, &r);
			DragWindow(wind,eventPt,&r); 
#else			
			DragWindow(wind,eventPt,&((**grayRgn).rgnBBox)); 
#endif
			break;
		case inGrow:
			if (doc && (growRes = GrowWindow(doc->docWindow, theEvent->where, &doc->limitRect))) {
				SizeWindow (doc->docWindow, LoWord (growRes),  HiWord (growRes), false);
				METHOD_DoResize (doc, false);
			}
			break;
		case inZoomIn:
		case inZoomOut:
			if (doc && TrackBox(wind,theEvent->where,windowCode)) {	/* point passed by value */
				SetPortWindowPort (wind);
				GetWindowPortBounds (wind, &r);
				EraseRect (&r);
				ZoomWindow(doc->docWindow,windowCode,doc->docWindow==FrontWindow());
				METHOD_DoResize (doc, true);
			}
			break;
		case inContent:
			if(wind!=FrontWindow()) {
				SelectWindow(wind);
				break;
			} else if (doc)
				METHOD_DoContent(doc,theEvent);
			break;
		case inDesk:
			break;
		default:
			break;
	}
	return;
}

	
void Scroll (DocumentPtr doc, ControlHandle theControl,short change)
{
	/* Ref: p. 214 */
	/* This should not have to be overridden (cf. p. 215). More likely, 
		METHOD_ScrollContents and METHOD_SetScrollBarValues will be overridden. */
		
	RgnHandle oldClip;
	long newValue;
	short diff=0;
	short oldValue;
	short minValue,maxValue;
	
	oldClip=NewRgn();
	GetClip(oldClip);
	
	oldValue = GetControlValue(theControl);
	newValue = oldValue + change;
	
	if(change<0) {
		minValue = GetControlMinimum(theControl);
		if(newValue < minValue)
			newValue = minValue;
	} else {
		maxValue = GetControlMaximum(theControl);
		if(newValue > maxValue)
			newValue = maxValue;
	}
	diff = oldValue - newValue;
	METHOD_FocusOnContent(doc);
	if(theControl == doc->vScroll)
		METHOD_ScrollContents(doc,0,diff);
	if(theControl == doc->hScroll)
		METHOD_ScrollContents(doc,diff,0);
		
	/* BH: inserted METHOD_AdjustScrollBars because this now does
		what METHOD_SetScrollBarValues did before */		
	METHOD_AdjustScrollBars (doc); 
	
	SetClip(oldClip);
	DisposeRgn(oldClip);

}

static void CombinedScroll (DocumentPtr doc,short dh,short dv)
{
	/* 
		This is Scroll for both directions simultaneously. It could
		be used for a hand tool (option-click). It is the working
		routine for Display Selection. 
	*/
		
	RgnHandle oldClip;
	long newValue;
	short diffH=0,diffV=0;
	short oldValue;
	short minValue,maxValue;
	
	oldClip=NewRgn();
	GetClip(oldClip);
		
	if(dh) {
		oldValue = GetControlValue(doc->hScroll);
		newValue = oldValue + dh;
	
		if(dh<0) {
			minValue = GetControlMinimum(doc->hScroll);
			if(newValue < minValue)
				newValue = minValue;
		} else {
			maxValue = GetControlMaximum(doc->hScroll);
			if(newValue > maxValue)
				newValue = maxValue;
		}
		diffH = oldValue - newValue;
	}
	if(dv) {
		oldValue = GetControlValue(doc->vScroll);
		newValue = oldValue + dv;
	
		if(dv<0) {
			minValue = GetControlMinimum(doc->vScroll);
			if(newValue < minValue)
				newValue = minValue;
		} else {
			maxValue = GetControlMaximum(doc->vScroll);
			if(newValue > maxValue)
				newValue = maxValue;
		}
		diffV = oldValue - newValue;
	}
		
	METHOD_ScrollContents(doc,diffH,diffV);
		
	/* BH: inserted METHOD_AdjustScrollBars because this now does
		what METHOD_SetScrollBarValues did before */		
	METHOD_AdjustScrollBars (doc); 
	
	SetClip(oldClip);
	DisposeRgn(oldClip);
}


static void OSEvent(EventRecord *event) 
{
	Boolean doConvert;
	unsigned char evType;
	DocumentPtr doc;
	
	evType = (unsigned char)(event->message >>24)&0x0FF;
	
	switch(evType) {
		case mouseMovedMessage:
			doc = FindDocument(FrontWindow());
			if (doc)
				METHOD_DoIdle (doc);
			break;
		case suspendResumeMessage:
			doConvert=event->message&2;
			if (event->message&resumeFlag) {
				gInBackground=false;
				DoResume(event,doConvert);
			} else {
				gInBackground=true;
				DoSuspend(event,doConvert);
			}
			break;
		default:
			break;
	}
}


static void DoSuspend(EventRecord *theEvent,Boolean convertClip)
{
	WindowPtr targetWindow;
    DocumentPtr doc;
    
	targetWindow=FrontWindow();
	if(doc = FindDocument(targetWindow)) {	/* Is it a Documents window? */
		METHOD_Deactivate(doc);
	}
}	
		

static void DoResume(EventRecord *theEvent, Boolean convertClip) 
{
	WindowPtr targetWindow;
    DocumentPtr doc;
    
	targetWindow=FrontWindow(); 		/* What window is it in?  */
	
	if(doc = FindDocument(targetWindow)) {	/* Is it a Documents window? */
		AdjustMenus(doc, 0);
		METHOD_Activate(doc);
	}
}


/****************************************************************************
**  OpenExistingFile opens a file and reads its contente into a 
**  document record
*/
static DocumentPtr OpenExistingFile(FSSpecPtr theSpecs, OSType type, Boolean readonly)
{
	DocumentPtr doc;
#if STATE
	Rect r;
#endif
	
	doc = FindDocumentFromFSSpec (theSpecs, type);

	if (doc) {
		SelectWindow (doc->docWindow); /*BH: bring window to the front */
		return doc;
	}
	
	if(!(doc = GetEmptyDocument()))
		return (DocumentPtr)0;
	
	doc->fDocType=type;
	doc->fileSpecs = *theSpecs;
	doc->fValidFSSpec = true;
	doc->fReadOnly = readonly;
	switch (type) {
		case 'TEXT':	
			AddTextDocumentMethods(doc);
				break;
			default:
				break;
	}
	if(METHOD_InitDoc (doc)) {
		if(METHOD_OpenDocFile(doc)) {
			if(METHOD_ReadDocFile(doc)) {
#if STATE
				if(doc->resourcePathRefNum) {
					if(doc->windowState) {
						r = (*doc->windowState)->userState;
						MoveWindow(doc->docWindow,r.left,r.top,true);
						SizeWindow(doc->docWindow,r.right-r.left,r.bottom-r.top,false);
						METHOD_DoResize(doc, true);
					}
				}
#endif
				ShowDocWindow(doc);
				AdjustMenus (doc, 0);  /*BH: inserted */
#if MARKS
				if(doc->marks) 
					FillMarkMenu(doc);
#endif
				return doc;
			}
			else
				CloseDocFile (doc);
		}
	}
	METHOD_Destructor (doc);
	return (DocumentPtr)0;
}

/****************************************************************************
**  OpenExistingFSSpec is the same as OpenExistingFile, except that it gets
**  the file type first
*/
static DocumentPtr OpenExistingFSSpec (FSSpec *spec, Boolean readonly) {
	FInfo info;
	OSErr err;

	err=FSpGetFInfo(spec, &info);
	if(err!=noErr)
		return (DocumentPtr)0;

	if(AcceptableFileType(info.fdType))
		return OpenExistingFile(spec, info.fdType, readonly);
	doMessage (16);
	return (DocumentPtr)0;
}

/****************************************************************************
**  OpenExistingFileDialog is the same as OpenExistingFile, except that it gets
**  the file from the user 
*/
static void OpenExistingFileDialog (Boolean all)
{
	StandardFileReply reply;
	long response=0;

	if (CountDocuments() >= MAXWINDS) {
		doMessage (4);
		return;
	}
	InitCursor();
	StandardGetFile(NULL,(all)?-1:NumFileTypes,MyFileTypes,&reply);
	if(reply.sfGood) 
		OpenExistingFile (&reply.sfFile, reply.sfType, all);
}



#if SYSTEM6
Boolean OpenDocFromFinder(void)
{
	short message;
	short count,i;
	AppFile theApp;
	FSSpec spec;
	Boolean fileOpened = false;
	OSErr err;
	long response=0;
	
	CountAppFiles(&message,&count);
	if(!count)
		return false;
		
	for(i=count;i;i--) {
		GetAppFiles(i,&theApp);
		err=FSMakeFSSpec(theApp.vRefNum,0,theApp.fName,&spec);
		
		if(AcceptableFileType(theApp.fType))
			if(InitDocFromExistingFile(theApp.fType,&spec)) 
				fileOpened = true;
	}
	return fileOpened;
}
#endif 

static Boolean AcceptableFileType(OSType theType)
{
	OSType *theTypeList;
	long i;
	
	theTypeList = MyFileTypes;
	
	if((NumFileTypes == 0) || (theTypeList == NULL))
		return true;
	
	for(i=0; i<NumFileTypes; i++) {
		if(theType == *theTypeList++)
			return true;
	}
	return false;
}


static void OpenNewDoc(void)
{
	DocumentPtr newDoc;

	if(newDoc = GetEmptyDocument()) {
		newDoc->fDocType = 'TEXT';
		newDoc->fileSpecs = DefaultSpecs;
		GetIndString(newDoc->fileSpecs.name,131,3);
		AddTextDocumentMethods (newDoc);
		if(METHOD_InitDoc(newDoc)) {
			/* Now make the data entry doc */
			METHOD_AdjustScrollBars(newDoc);
			newDoc->fValidFSSpec=false;
			ShowDocWindow(newDoc);
			AdjustMenus(newDoc, 0);  /*BH: inserted */
		} else 
			METHOD_Destructor(newDoc);
	}
}


static void WindowMenuSelect(short docNumber)
{
	short i,cnt;
	
	for(i=cnt=0;i<MAXWINDS;i++) {
		if(Documents[i].fValidDoc) {
			if(++cnt == docNumber) {
				if(Documents[i].docWindow != FrontWindow())
					SelectWindow(Documents[i].docWindow);
				return;
			}
		}
	}
}



static void TileWindows(void)
{
	long i,j,nWinds,nRows,nCols;
	short wWidth,wHeight;
	Rect base,wRect;
	DocumentPtr doc;
	WindowPtr front;
	GDHandle mainGD;
	
	front=0;
	for(nWinds=i=0;i<MAXWINDS;i++) {
		if(Documents[i].docData) {
			if(!front)
				front=Documents[i].docWindow;
			nWinds++;
		}
	}
	if(nWinds) {
		nCols=0;
		do {
			nRows = nWinds/++nCols;
		} while(nRows>nCols+2);
		
		mainGD=GetMainDevice();
		base=(**mainGD).gdRect;
		base.top += 4 + GetMBarHeight();
;
		wWidth=(base.right-base.left-(nCols-1)*4)/nCols;
		wHeight=(base.bottom-base.top-4-(nRows-1)*4)/nRows;

		base.right=base.left+wWidth;
		base.bottom=base.top+wHeight;
		doc=&Documents[0];
		for(i=0;i<nCols;i++) {
			for(j=0;j<nRows;j++) {
				wRect=base;
				OffsetRect(&wRect,(wWidth+4)*i,(wHeight+4)*j);
				while(!doc->docData && doc<&Documents[MAXWINDS-1])
					doc++;
				MoveWindow(doc->docWindow,wRect.left,wRect.top+20,!front);
				SizeWindow(doc->docWindow,wRect.right-wRect.left,wRect.bottom-wRect.top-20,false);
				METHOD_DoResize(doc, true);
				doc++;
			}
		}
		if(front)
			SelectWindow(front);
	}
}

static void StackWindows(void)
{
	long i,nWinds;
	short shift;
	Rect base;
	WindowPtr wind;
	DocumentPtr doc;
	GDHandle mainGD;
	
	for(nWinds=0,i=0;i<MAXWINDS;i++) {
		if(Documents[i].docData) 
			nWinds++;
	}
	mainGD = GetMainDevice ();
	base=(**mainGD).gdRect;

	base.top+=4+GetMBarHeight ();
	shift=20*nWinds;
	base.top+=shift;
	base.left+=shift;
	
	for(wind=FrontWindow(); wind; wind=GetNextWindow (wind)) {
		if (doc = FindDocument (wind) ) {
			shift=10*nWinds;
			OffsetRect(&base, -20, -20);
			MoveWindow(doc->docWindow,base.left,base.top+20,false);
			SizeWindow(doc->docWindow,base.right-base.left,base.bottom-base.top-20,false);
			METHOD_DoResize(doc, true);
			nWinds--;
		}
	}
	GetLogWindowSize ();
}



#if MARKS

MarkRecPtr GetIndMark(Ptr mark, short index)
{
	short nMarks,i;
	
	nMarks = *((short *) mark);
	mark += 2;
	for(i=0;i<index && i<nMarks; i++) 
		 mark+=sizeofMark(mark);
	return (i==index)? (MarkRecPtr)mark : 0;
}
#endif

#if MARKS
Ptr switchMarks(MarkRecPtr m0,MarkRecPtr m1)
{
	Str255 temp;
	Ptr m;
	
	m=(Ptr)m1;
	m+=m1->label-m0->label;
	BlockMove(m0,temp,m0->label+9);
	BlockMove(m1,m0,m1->label+9);
	BlockMove(temp,m,9+((MarkRecPtr)temp)->label);
	return m;
}
#endif


#if MARKS

/* nameRequested is a c string */

Boolean RequestDialog(short strID,char *nameRequested)
{
	DialogPtr requestDialog;
	short itemHit,itemType;
	Handle itemHand;
	Rect box;
	char *p;
	Str255 message;

	requestDialog=GetNewDialog(rRequestDialog, nil, (WindowPtr)(-1));

	if(!requestDialog) {
		SysBeep(3);SysBeep(3);SysBeep(3);
		return false;
	}
			
	/*	Truncate the selection to one line and make it less than 63 chars. */
	for(p=nameRequested;*p && *p!='\n';p++) ;
	*p='\0';
	c2pstr(nameRequested);
	if(*nameRequested>63)
		*nameRequested=63;
	*(nameRequested+*nameRequested+1)=0;
	
	GetDialogItem(requestDialog,3,&itemType,&itemHand,&box);
	GetIndString(message,128,strID);	
	SetDialogItemText(itemHand,message);
	GetDialogItem(requestDialog,4,&itemType,&itemHand,&box);
	SetDialogItemText(itemHand,(unsigned char *) nameRequested);
	SelectDialogItemText(requestDialog,4,0,kMaxShort);
	GetDialogItem(requestDialog,5,&itemType,&itemHand,&box);
	SetDialogItem(requestDialog,5,itemType,(Handle)doButtonUPP,&box);

	for(;;) {
		
		ModalDialog(DialogStandardFilterUPP,&itemHit);   /* BH: replaced DialogStandardFilter by DialogStandardFilterUPP */

		if(itemHit==iYes) {					/* Okay */
			GetDialogItem(requestDialog,4,&itemType,&itemHand,&box);
			GetDialogItemText(itemHand,(unsigned char *) nameRequested);
			if(*nameRequested>63)
				*nameRequested=63;
			DisposeDialog (requestDialog);
			return true;
		} else if(itemHit==iNo) {				/* Cancel */
			DisposeDialog (requestDialog);
			return false;
		}
	}
}
#endif

#if MARKS
void sortMarks(DocumentPtr doc, Boolean how)
{
	Ptr mark,firstMark;
	short i,nMarks;
	Boolean changed;
	MarkRecPtr m0,m1;
	
	if(doc->marks) {
		HLock(doc->marks);
		mark = *doc->marks;
		nMarks = *((short *)mark);
		firstMark=mark+2;
		/* This is a unidirectional bubble sort. */
		do {
			mark=firstMark;
			m1=(MarkRecPtr)mark;
			for(nMarks--,changed=i=0;i<nMarks;i++) {
				m0=m1;
				mark+=9+m1->label;
				m1=(MarkRecPtr)mark;
				if((how)?	m0->selStart>m1->selStart :
							IUCompString((unsigned char *) &m0->label,(unsigned char *) &m1->label)>0) {
					mark=switchMarks(m0,m1);
					m1=(MarkRecPtr)mark;
					changed=true;
				}
			}
		} while(changed);
		HUnlock(doc->marks);
		FillMarkMenu(doc);
	}
}
#endif

#if MARKS
void InsertMark(DocumentPtr doc,long selStart,long selEnd,char *p)
{
	Ptr mark,firstMark;
	short i,nMarks,itemType;
	OSErr err;
	MarkRecPtr m0;
	long whereInMarks,oldSize,newSize;
	
	/*	p is the tentative mark name and is a c string when passed,
		but is turned into a pstring by RequestDialog. */
		
	if(RequestDialog(1,p)) {
		if(doc->marks) {
			HLock(doc->marks);
			mark = *doc->marks;
			nMarks = *((short *)mark);
			firstMark=mark+2;
			i=*p;
			if(!(i%2)) {
				(*p)++;
				p[*p]='\0';
			}
			whereInMarks=Munger(doc->marks,2,p,*p+1,0,0);
			if(whereInMarks>=0) {		/* This mark already exists */
				*p=i;
				if(doConfirmDialog(2,(unsigned char *) p)) {
					*p+=(i%2)? 0:1;
					m0 = (MarkRecPtr)(mark+whereInMarks-8);
					m0->selStart=selStart;
					m0->selEnd=selEnd;
				}
				return;
			}
			/* Insert a new mark. Put it at beginning of new Handle so the bubble sort will
				position it in one iteration. */
			HUnlock(doc->marks);
			oldSize=GetHandleSize(doc->marks);
			newSize=*p+(((*p)%2)? 9:10);
			SetHandleSize(doc->marks,oldSize+newSize);
			err=MemError();
			if(err==noErr) {
				HLock(doc->marks);
				BlockMove(*doc->marks+2,*doc->marks+newSize+2,oldSize-2);
				*((short *)*doc->marks)=nMarks+1;
				m0 = (MarkRecPtr)(*doc->marks + 2);
				m0->selStart=selStart;
				m0->selEnd=selEnd;
				BlockMove(p,&m0->label,*p+1);
				HUnlock(doc->marks);
#if 0
				if(doc->resourcePathRefNum)
					ChangedResource(doc->marks);
#endif
				GetItemMark(MarkMenu,iAlphabetical,&itemType);
				sortMarks(doc,!itemType);	/* Calls FillMarkMenu */
			} else {
				/* A mem error */ 
			
			}
		} else {
			newSize=*p+(((*p)%2)? 11:12);
			doc->marks=NEWHANDLE(newSize);
			if(doc->marks && !MEMERROR ()) {
				HLock(doc->marks);
				*((short *)*doc->marks)=1;
				m0 = (MarkRecPtr)(*doc->marks + 2);
				m0->selStart=selStart;
				m0->selEnd=selEnd;
				BlockMove(p,&m0->label,*p+1);
				if(!(m0->label%2)) {
					m0->label++;
					p=&m0->label;
					p[m0->label]='\0';
				}
				HUnlock(doc->marks);
				FillMarkMenu(doc);
			}
		}
	}
}
#endif

#if MARKS
ListHandle FillMarkList(DocumentPtr doc,WindowPtr unMarkDialog, long selStart, long selEnd)
{
	short i,nMarks;
	Ptr mark;
	MarkRecPtr m0;
	ListHandle theList=0;
	Rect box,dataBounds;
	Point cellSize,cell;
	short itemType;
	Handle itemHand;
	
	nMarks = *((short *)*doc->marks);
	
	GetDialogItem(unMarkDialog,4,&itemType,&itemHand,&box);
	InsetRect(&box,1,1);

	cellSize.v=15;
	cellSize.h=box.right-box.left;

	box.bottom=box.top+cellSize.v*((box.bottom-box.top)/cellSize.v);
	box.right-=15;

	SetRect(&dataBounds,0,0,1,nMarks);
	theList=LNew(&box,&dataBounds,cellSize,0,unMarkDialog,false,false,false,true);
	if(!theList) {
		SysBeep(2);
		return 0;
	}

	HLock(doc->marks);

	cell.h=0;
	cell.v=0;
	mark=*doc->marks+2;
	for(i=0;i<nMarks;i++) {
		m0=(MarkRecPtr)mark;
		LSetCell(mark+9,m0->label,cell,theList);
		if(m0->selStart==selStart && m0->selEnd==selEnd)
			LSetSelect(true,cell,theList);
		cell.v++;
		mark+= 9+m0->label;
	}
	HUnlock(doc->marks);
	return theList;
}
#endif

#if MARKS
short DeleteMark(DocumentPtr doc,short markIndex)
{
	short nMarks,i;
	Ptr mark;
	long len,delta,newSize;
	
	if(doc->marks) {
		nMarks=*((short *)*doc->marks);
		if(markIndex>nMarks)
			return nMarks;
		if(--nMarks) {
			len=GetHandleSize(doc->marks);
			HLock(doc->marks);
			*((short *)*doc->marks)=nMarks;
			mark=*doc->marks + 2;
			for(i=0;i<markIndex;i++)
				mark+=9+((MarkRecPtr)mark)->label;
			delta = 9 + ((MarkRecPtr)mark)->label;
			newSize=(long)*doc->marks;
			newSize+=len;
			newSize-=(long)mark;
			newSize-=delta;

			if(markIndex<nMarks)	/* not last mark to be deleted */
				BlockMove(mark+delta,mark,newSize);
			HUnlock(doc->marks);
			newSize=len-delta;
			SetHandleSize(doc->marks,newSize);
			i=(short)MemError();
			if(i!=noErr) {
				DisposeHandle(doc->marks);
				doc->marks=0;
			}
		} else {
			SetHandleSize(doc->marks,2);
			*((short *)*doc->marks)=nMarks;
		}
		FillMarkMenu(doc);
		return nMarks;
	}
}
#endif

/*---------------------------------------------------------------------------
	This is a universal filter for modal dialogs that use List Manager lists.
	It does the conventional checking for double clicks and return or enter
	key hits.
-----------------------------------------------------------------------------*/

pascal Boolean listFilter(DialogPtr dialog,EventRecord *theEvent,short *itemHit)
{
	ListHandle list;
	Point mouseLoc,cell;
	short modifiers;
	Rect box;
	short itemType;
	Handle itemHand;
	Boolean selected;
	
	SetPortDialogPort(dialog);
	GetDialogItem(dialog,1,&itemType,&itemHand,&box);

	cell.h=cell.v=0;
	list=(ListHandle)GetWRefCon(GetDialogWindow (dialog));
	selected=LGetSelect(true,&cell,list);
	
	if(theEvent->what==mouseDown) {
		mouseLoc=theEvent->where;
		modifiers=theEvent->modifiers;
		GlobalToLocal(&mouseLoc);
		if(LClick(mouseLoc,modifiers,list)) {	/* Double Click */
			*itemHit=1;
			return true;
		}
	} else if(theEvent->what==keyDown) {
		if(DialogStandardKeyDown(dialog,theEvent,itemHit))
			return true;
	}
	HiliteControl((ControlHandle)itemHand,(selected)? 0:255);
	return false;
}

void UpdateList (ListHandle TheListHandle)
{
	Rect ViewRect;
	RgnHandle ListUpdateRgn;

	SetPort((**TheListHandle).port);
	/*	Get the List manager to update the list. */
	ViewRect = (**TheListHandle).rView;
	LSetDrawingMode(true, TheListHandle);
	ListUpdateRgn = NewRgn();
	RectRgn(ListUpdateRgn,&ViewRect);
	LUpdate(ListUpdateRgn, TheListHandle);
	/*	Draw the border */
	InsetRect(&ViewRect, -1, -1);
	FrameRect(&ViewRect);
	/*	Clean up after ourselves */
  	DisposeRgn(ListUpdateRgn);
}

#if MARKS
void DoUnmark(DocumentPtr doc,long selStart,long selEnd)
{
	DialogPtr unmarkDialog;
	Boolean pau=false;
	short itemHit,itemType;
	Handle itemHand;
	ListHandle list;
	Rect box;
	Point cell;
	Str255 buf;
	
	unmarkDialog=GetNewDialog(rUnmarkDialog, nil, (WindowPtr)(-1));

	if(!unmarkDialog) {
		SysBeep(3);SysBeep(3);SysBeep(3);
		return;
	}
	
	if(list=FillMarkList(doc,unmarkDialog,selStart,selEnd)) {
		SetWRefCon(unmarkDialog,(long)list);
		LAutoScroll(list);
		UpdateList(list);
				
		GetIndString(buf,128,5);
		GetDialogItem(unmarkDialog,3,&itemType,&itemHand,&box);
		SetDialogItemText(itemHand,buf);
		
		GetDialogItem(unmarkDialog,5,&itemType,&itemHand,&box);
		SetDialogItem(unmarkDialog,5,itemType,(Handle)doButtonUPP,&box);
		while(!pau) {
			ModalDialog(listFilter,&itemHit);
				if(itemHit==1) {			/* Okay */
				pau=true;
				cell.h=cell.v=0;
				for(itemType=0;LGetSelect(true,&cell,list);itemType++) {
					DeleteMark(doc,cell.v-itemType);
					cell.v++;
				}
			} else if(itemHit==2) {		/* Cancel */
				pau=true;
			}
		}
	}
	LDispose(list);
	DisposeDialog (unmarkDialog);
}
#endif

/*	
	This works okay. It operates directly on the MENU resource in memory.
 	This is not illegal.
*/

#if MARKS
void FillMarkMenu(DocumentPtr doc)
{
	register Ptr mark,dest;
	register long i,j,nMarks;
	Boolean order=false,putUp;
	Size baseLength,markLength;
	
	OSErr err;
	CursHandle cH;
	
	if(doc->markMenu) {
		cH=GetCursor(watchCursor);
		if(cH)
			SetCursor(*cH);

		if(putUp=(MarkMenu==doc->markMenu))
			DeleteMenu(MARK_ID);
			
		DisposeHandle((Handle)doc->markMenu);
		if (doc->resRefNum) {
			UseResFile (doc->resRefNum);
			doc->markMenu=(MenuHandle)Get1Resource('MENU',MARK_ID);
			err=HandToHand((Handle *)&doc->markMenu);
			if(err!=noErr)
				return;
		}
			
		if(doc->marks) {
			nMarks=*(short *)*doc->marks;
			
			/* Later on, only do the following if nMarks>50 */
			
			baseLength=GetHandleSize((Handle)doc->markMenu);
			markLength=GetHandleSize(doc->marks)-nMarks*4-2;
			
			SetHandleSize((Handle)doc->markMenu,baseLength+markLength);
			err=MemError();
			if(err!=noErr)
				return;
					
			HLock(doc->marks);
	
			/* 1. Check for order */
			mark=*doc->marks+2;
			for(j=i=0;i<nMarks;i++,mark+=sizeofMark(mark)) {
				if(j>((MarkRecPtr)mark)->selStart) {
					CheckItem(doc->markMenu,iAlphabetical,true);
					break;
				}
				j=((MarkRecPtr)mark)->selStart;
			}
			mark=*doc->marks+10;
			
			/* 2. Move the mark labels into the MENU resource structure */
			HLock((Handle)doc->markMenu);
			memset((*((Handle)doc->markMenu))+baseLength,0,markLength);
			
			mark=*doc->marks+10;
			dest=(*((Handle)doc->markMenu))+baseLength-1;
						
			while(nMarks) {
				for(j=*mark+1,i=0;i<j;i++) 
					*dest++ = *mark++;
				mark+=8;
				dest+=4;
				nMarks--;
			}
				
			HUnlock(doc->marks);
			HUnlock((Handle)doc->markMenu);
			
			CalcMenuSize(doc->markMenu);
			
			if(putUp) {
				MarkMenu=doc->markMenu;
				InsertMenu(MarkMenu,WINDOW_ID);
			}
		}
	}
	InitCursor();
}
#endif

/*----------------------------------------------------------------------

	Marks whose selBegin is greater than a value are moved by delta, 
	whether delta is positive or negative.

	Marks whose selEnd is less than a value are not changed.

	If delta is negative then marks completely enclosed in a range are 
	deleted.

	Marks that are intersected by a range are extended or decreased.

	The range and delta can usually be determined from the undo 
	parameters. In continuous typing, however, this is not possible as 
	an event that triggers a need to update the mark (e.g. a mouse-down 
	in the menu bar) may not trigger the formation of a new undo buffer.
	
-----------------------------------------------------------------------*/

#if MARKS
void UpdateMarks(DocumentPtr doc,long selStart,long selEnd,long delta, long docLength)
{
	Ptr mark;
	short nMarks,i,mSize;

#if 0
/*=============== Debug Code ===========*/
	long offset;
	TE32KHandle tH;
	MarkRecPtr theMark;
	char *p,*q;
/*=============== Debug Code ===========*/
#endif
	if(doc->marks && delta) {
		HLock(doc->marks);
		nMarks = *((short *)*doc->marks);
		mark=*doc->marks+2;
		
		/*	
			If a mark is deleted, mSize is set to zero so that we won't increment 
			past the newly current mark. 
		*/
			
		for(i=0;i<nMarks;i++,mark+=mSize) {
			mSize = sizeofMark(mark);
			
			if(selStart <= selEnd) {
				if(selEnd < ((MarkRecPtr)mark)->selStart) {	
					/* 	
						Most common case: 
							No overlap with mark and mark is after the edited region. 
					*/
					
					((MarkRecPtr)mark)->selStart += delta;
					((MarkRecPtr)mark)->selEnd += delta;
					
				} else if(selStart<((MarkRecPtr)mark)->selStart 
							&& selEnd>((MarkRecPtr)mark)->selEnd) {
					/* 
						Extreme case: 
							Change overlaps both ends of mark. Either delete or move mark.
					*/
					
					if(delta<0) {					/* Negative delta means text has been deleted. */
						nMarks=DeleteMark(doc,i);	/* N.B. DeleteMark unlocks doc->marks handle. */
						if(nMarks) {
							HLock(doc->marks);
							mark=(Ptr)GetIndMark(*doc->marks,i--);
							if(!mark) {
								HUnlock(doc->marks);
								return;
							}
						}  
						mSize=0;
					} else {						/* Text added. Move mark. */
						((MarkRecPtr)mark)->selStart += delta;
						((MarkRecPtr)mark)->selEnd += delta;
					}
				} else if(selStart <= ((MarkRecPtr)mark)->selEnd 
						|| selEnd <= ((MarkRecPtr)mark)->selEnd) {
					/*
						Mark partially overlapped by edited region.
					*/
					
					((MarkRecPtr)mark)->selEnd += delta;
				}
			} else {
				if(selStart < ((MarkRecPtr)mark)->selStart) {	
					/* Most common case: No overlap. */
					((MarkRecPtr)mark)->selStart += delta;
					((MarkRecPtr)mark)->selEnd += delta;
				} else if(selEnd<((MarkRecPtr)mark)->selStart && selStart>((MarkRecPtr)mark)->selEnd) {
					/* Extreme case, change overlaps both end. */
					if(delta<0) {
						((MarkRecPtr)mark)->selStart = selEnd;
						((MarkRecPtr)mark)->selEnd = selEnd;
					} else {
						((MarkRecPtr)mark)->selStart += delta;
						((MarkRecPtr)mark)->selEnd += delta;
					}
				} else if(selEnd <= ((MarkRecPtr)mark)->selStart) {		/* deleting back through beginning of mark */
					if(delta<0) {
						((MarkRecPtr)mark)->selStart = selEnd;
						((MarkRecPtr)mark)->selEnd = selEnd;
					} else {
						((MarkRecPtr)mark)->selStart += (selStart-selEnd);
						((MarkRecPtr)mark)->selEnd += delta;
					}
					
				} else if(selEnd <= ((MarkRecPtr)mark)->selEnd) {		/* deleting back and encountering mark	*/
					if(delta<0)
						((MarkRecPtr)mark)->selEnd = selEnd;
					else
						((MarkRecPtr)mark)->selEnd += (selStart-selEnd);
				}
			}
			/*
				If a mark is beyond the current document. Delete it. 
			*/
			if(mSize && docLength>=0 && (((MarkRecPtr)mark)->selEnd>docLength 
						|| ((MarkRecPtr)mark)->selStart>docLength)) { 
				if(nMarks=DeleteMark(doc,i)) {
					HLock(doc->marks);
					mark=(Ptr)GetIndMark(*doc->marks,i--);
					if(!mark) {
						HUnlock(doc->marks);
						return;
					}
				}
				mSize=0;
			}  
		}
		if(doc->marks)		/* It could have been disposed of. */
			HUnlock(doc->marks);
	}
	doc->fNeedToUpdateMarks = false;
	
#if 0
/*=============== Debug Code ===========*/

	tH =  TE32KHANDLE doc->docData;
	if(tH && doc->marks) {
		theMark = (MarkRecPtr)(*doc->marks+2);
		offset = theMark->selStart;
		p=*(**tH).hText+offset;
		q=&theMark->label;
		if(*p != q[1])
			SysBeep(7);
		offset=*q;
		if(!*(q+offset))
			offset--;
		if(*(p+offset-1) != *(q+offset))
			SysBeep(7);
	}
#endif
}
#endif

/*--------------InitAEStuff installs AppleEvent handlers ----------------*/

static struct AEinstalls {    /* BH: moved here */
    AEEventClass theClass;
    AEEventID theEvent;
    AEEventHandlerProcPtr theProc;  /*BH: changed EventHandlerProcPtr to AEEventHandlerProcPtr */
	AEEventHandlerUPP theUPP;   /* BH: inserted for PowerMac */
} HandlersToInstall[] =  /* BH: handler UPPs must be global (?) */
		{ 	{ kCoreEventClass, kAEOpenApplication, AEOpenHandler, (AEEventHandlerUPP)(long)0},
			{ kCoreEventClass, kAEOpenDocuments, AEOpenDocHandler, (AEEventHandlerUPP)(unsigned long)0	},
			{ kCoreEventClass, kAEQuitApplication, AEQuitHandler, (AEEventHandlerUPP)(unsigned long)0	},
			{ kCoreEventClass, kAEPrintDocuments, AEPrintHandler, (AEEventHandlerUPP)(unsigned long)0	}
#ifdef GAPVER
			,
			/* The above are the four required AppleEvents. */
			{ FCREATOR, 'exec', AEExecuteGAPCommandHandler, (AEEventHandlerUPP)0L },
			{ FCREATOR, 'help', AEGetGAPHelpCommandHandler, (AEEventHandlerUPP)0L }
#endif
    	};

static void InitAEStuff(void)
{
    OSErr aevtErr = noErr;
	register qq;

    /*	
		The following series of calls installs all our AppleEvent Handlers.
		These handlers are added to the application event handler list that 
		the AppleEvent manager maintains.  So, whenever an AppleEvent happens
		and we call AEProcessEvent, the AppleEvent manager will check our
		list of handlers and dispatch to it if there is one.
    */
	for (qq = 0; qq < ((sizeof(HandlersToInstall) / sizeof(struct AEinstalls))); qq++) {
		HandlersToInstall[qq].theUPP = NewAEEventHandlerProc (HandlersToInstall[qq].theProc);   /* for Power Mac */
		aevtErr = AEInstallEventHandler(HandlersToInstall[qq].theClass, HandlersToInstall[qq].theEvent,
                                            HandlersToInstall[qq].theUPP, 0, false);
		if (aevtErr) {
			ExitToShell();			/* just fail, baby */
		}
    }
}


static OSErr processOpenPrint(const AppleEvent *messagein, Boolean printIt);

/* This is the standard Open Application event.  */
pascal OSErr AEOpenHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
#pragma unused (messagein,reply,refIn)
    return noErr;
}

/* end AEOpenHandler */

/* Open Doc, opens our documents.  Remember, this can happen at application start AND */
/* anytime else.  If your app is up and running and the user goes to the desktop, hilites one */
/* of your files, and double-clicks or selects Open from the finder File menu this event */
/* handler will get called. Which means you don't do any initialization of globals here, or */
/* anything else except open then doc.  */
/* SO-- Do NOT assume that you are at app start time in this */
/* routine, or bad things will surely happen to you. */

pascal OSErr AEOpenDocHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
	OSErr err;
	
#pragma unused (refIn,reply)
	err = processOpenPrint(messagein, false);
	return err;
}

pascal OSErr AEPrintHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{                                                           /* no printing handler in yet, so we'll ignore this */
	OSErr err;
	
#pragma unused (refIn,reply)
   
	err = processOpenPrint(messagein, true);
	return err;
}

pascal OSErr AEQuitHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
#pragma unused (messagein,refIn,reply)
    DoQuit(true);
    return noErr;
}

/*-------------------------------------------------------------------------------------

	MissedAnyParameters

	Used to check for any unread required parameters. Returns true if we missed at
	least one.

--------------------------------------------------------------------------------------*/

Boolean MissedAnyParameters(const AppleEvent *message)
{
    OSErr err;
    DescType ignoredActualType;
    AEKeyword missedKeyword;
    Size ignoredActualSize;
    EventRecord event;
    
    err = AEGetAttributePtr(message, keyMissedKeywordAttr, typeKeyword, &ignoredActualType, (Ptr)&missedKeyword,
                            sizeof(missedKeyword), &ignoredActualSize);
    
    /* no error means that we found some more.*/
    
    if (!err) {
        event.message = *(long *)&ignoredActualType;
        event.where = *(Point *)&missedKeyword;
        doMessage(7);
        err = errAEEventNotHandled;
    }
    
    /* errAEDescNotFound means that there are no more parameters. If we get */
    /* an error code other than that, flag it. */
    
    else if (err != errAEDescNotFound) {
        doMessage(8);
        
    }
    return(err != errAEDescNotFound);
}

/*-------------------------------------------------------------------------------------

 	processOpenPrint handles ODOC and PDOC events.  Both events open a document, 
 	one prints it 
--------------------------------------------------------------------------------------*/

static OSErr processOpenPrint(const AppleEvent *messagein, Boolean printIt)
{
    OSErr err;
    OSErr err2;
    AEDesc theDesc;
    FSSpec theFSS;
    register qq;
    long numFilesToOpen;
    AEKeyword ignoredKeyWord;
    DescType ignoredType;
    Size ignoredSize;
    DocumentPtr doc;
	
	err = AEGetParamDesc(messagein, keyDirectObject, typeAEList, &theDesc);
	if (err) 
		doMessage(9);

	if (!MissedAnyParameters(messagein)) {
        
		/* Got all the parameters we need. Now, go through the direct object, */
		/* see what type it is, and parse it up. */
        
		if (err = AECountItems(&theDesc, &numFilesToOpen)) {
			doMessage(10);
		} else {
			for (qq = 1; ((qq <= numFilesToOpen) && (!err)); ++qq) {
				if (err = AEGetNthPtr(&theDesc, qq, typeFSS, &ignoredKeyWord, &ignoredType, (Ptr)&theFSS, sizeof(theFSS),
						&ignoredSize)) {
					doMessage(11);
                    
				} else {
					doc=OpenExistingFSSpec (&theFSS, false);
					if(doc) {
						DefaultSpecs=theFSS;
#if 0
						/*======= TN 80 technique for setting SF Default Vol =====*/
						/*BH: prefer the Power Mac compatible code using LM...*/
						LMSetSFSaveDisk(-1 * theFSS.vRefNum);  
						LMSetCurDirStore (theFSS.parID); /*==== Global Variable fill =====*/
#endif
					}
				}
				if (printIt && doc) {
                    METHOD_DoPrint(doc);
					DoClose(doc, true);
				}
			}												/* for qq = ... */
		}													/* AECountItems OK */
	}														/* Got all necessary parameters */
    
	if (err2 = AEDisposeDesc(&theDesc)) 
		doMessage(12);

	return(err ? err : err2);
}



