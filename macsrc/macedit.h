/****************************************************************************
**
*W  macedit.h                   GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the declarations for the built-in text editor.
*/
#if !TARGET_API_MAC_CARBON
#include <Files.h>
#include <Quickdraw.h>
#include <Dialogs.h>
#include <Printing.h>
#include <Palettes.h>
#include <StandardFile.h>
#include <Lists.h>
#include <Events.h>
#include <assert.h>
#endif

#if TEMPMEM
	#define NEWHANDLE(h) TempNewHandle (h, &gMemError)
	#define MEMERROR() gMemError
#else
	#define NEWHANDLE(h) NewHandle (h)
	#define MEMERROR() MemError ()
#endif

#define	LEFTARROW			28
#define	RIGHTARROW			29
#define UPARROW				30
#define DOWNARROW			31
#define	TAB					'\t'
#define DELETE				0x08
#define	RETURN				0x0D
#define	ENTER				0x03
#define LINEFEED			0x0A
#define HOME				0x01
#define END					0x04
#define PAGEUP				0x0B
#define PAGEDOWN			0x0C
#define FWDDELETE			0x7F
#define ESCAPE				0x1B
#define NEWLINE RETURN    /*BH: 	NEWLINE is the character that marks line ends in hText 
									RETURN is the character code of the Return key. 
									LINEFEED should not be needed below */
#define ISNEOL(c) (c!=RETURN && c!=LINEFEED)
#define ISEOL(c) (c==RETURN || c==LINEFEED) 

#define iYes 1
#define iNo 2
#define iCancel 3  /*BH: exchanged iNo and iCancel because dialog need not have iCancel */
#define kMaxShort 32767


#define OutOfMemory -1
#define DiskErr -2
#define PagingError -3

/****************************************************************************
**
**  type definitions 
*/
#pragma options align=mac68k

typedef struct MPSRWindowResource {		/* MPSR 1005 */
	short fontSize;
	char fontName[32];
	short fontWidth;	/* 0006 */
	short tabWidth;		/* 0004 */
	Rect userState;
	Rect stdState;
	unsigned long modifiedDate;
	long selStart;
	long selEnd;
	long vScrollValue;
	unsigned char wordWrap;	
	unsigned char showInvisibles;	
} MPSRWindowResource, *MPSRPtr;

#pragma options align=reset

struct DocumentRecord {
	WindowPtr 		docWindow;
	ControlHandle	hScroll;
	ControlHandle	vScroll;
	Boolean 		fNoGrow;
	short			hOffset,vOffset;
	TE32KHandle		docData;
	OSType			fDocType;
	OSType			fDocCreator;
	FSSpec			fileSpecs;
	short			windResource;
	short			dataPathRefNum;

#if MARKS || STATE
	short			resourcePathRefNum;
#endif

#if !TARGET_API_MAC_CARBON
	THPrint			fPrintRecord;
#endif
	Boolean			fValidDoc;
	Boolean			fNeedToSave;

#if MARKS
	Boolean			fNeedToUpdateMarks;
#endif

	Boolean			fValidFSSpec;
	Boolean			fHaveSelection;
	Boolean			fCanUndo;
	Boolean			fReadOnly;
	Rect			limitRect;

#if STATE
	MPSRWindowResource ** windowState;
#endif

#if MARKS
	Handle			marks;
	MenuHandle		markMenu;
#endif

	Boolean	(* mInitDoc) (struct DocumentRecord * );
	Boolean	(* mOpenDocFile) (struct DocumentRecord * );
	Boolean	(* mDestructor) (struct DocumentRecord *);
	Boolean (* mReadDocFile) (struct DocumentRecord * );
	Boolean	(* mWriteDocFile) (struct DocumentRecord * );
	Boolean	(* mReadIntoGAP) (struct DocumentRecord *, Boolean, Boolean);

#if MARKS || STATE
	Boolean	(* mWriteDocResourceFork) (struct DocumentRecord * );
#endif

	void 	(* mDoPageSetup) (struct DocumentRecord * );
	void 	(* mDoPrint) (struct DocumentRecord * );
	
	/* Event actions */
	void 	(* mDraw) (struct DocumentRecord * , Rect *, short);
	void 	(* mActivate) (struct DocumentRecord * );
	void 	(* mDeactivate) (struct DocumentRecord * );
	
	void 	(* mDoContent) (struct DocumentRecord * , EventRecord *);
	void 	(* mDoKeyDown) (struct DocumentRecord * , EventRecord *);
	Boolean	(* mConvertKey) (struct DocumentRecord * , EventRecord *);
	void 	(* mDoIdle) (struct DocumentRecord * );
	void 	(* mAdjustCursor) (struct DocumentRecord * ,Point);
	void 	(* mDoResize) (struct DocumentRecord * , Boolean);
	
	/* Edit menu and clipboard functions */
	Boolean	(* mDoDocMenuCommand) (struct DocumentRecord * ,short,short,short);
	void 	(* mAdjustDocMenus) (struct DocumentRecord *, short );
	void 	(* mDoCut) (struct DocumentRecord * );
	void 	(* mDoCopy) (struct DocumentRecord * );
	void 	(* mDoPaste) (struct DocumentRecord * );
	void 	(* mDoClear) (struct DocumentRecord * );
	void 	(* mDoSelectAll) (struct DocumentRecord * );
	void 	(* mDoUndo) (struct DocumentRecord * );
	
	/* Scrolling methods */
	void 	(* mFocusOnContent) (struct DocumentRecord * );   /* set drawing region to contents part of window, i.e. w/o controls */
	void 	(* mFocusOnDocument) (struct DocumentRecord * );   /* set drawing region to entire window */
	void 	(* mAdjustScrollBars) (struct DocumentRecord * );   /* adjust scroll bars according to document status */
	short 	(* mGetVertSize) (struct DocumentRecord * );
	short 	(* mGetHorizSize) (struct DocumentRecord * );
	short 	(* mGetVertLineScrollAmount) (struct DocumentRecord * );
	short 	(* mGetHorizLineScrollAmount) (struct DocumentRecord * );
	short 	(* mGetVertPageScrollAmount) (struct DocumentRecord * );
	short 	(* mGetHorizPageScrollAmount) (struct DocumentRecord * );
	void 	(* mDisplaySelection) (struct DocumentRecord * );
	void 	(* mScrollContents) (struct DocumentRecord * ,short,short);
	void 	(* mGetContentRect) (struct DocumentRecord * , Rect *);
};

typedef struct DocumentRecord DocumentRecord, * DocumentPtr;

typedef struct {
	long selStart;
	long selEnd;
	char label;
} MarkRec, *MarkRecPtr;

/****************************************************************************
**
**  method macros
*/
#define METHOD_InitDoc(w) (*((w))->mInitDoc) (w)
#define METHOD_OpenDocFile(w) (*((w))->mOpenDocFile) (w)
#define METHOD_ReadIntoGAP(w, b1, b2) (*((w))->mReadIntoGAP) (w, b1, b2)
#define METHOD_Destructor(w) (*((w))->mDestructor) (w)
#define METHOD_OpenDocFile(w) (*((w))->mOpenDocFile) (w)
#define METHOD_WriteDocFile(w) (*((w))->mWriteDocFile) (w)
#define METHOD_ReadDocFile(w) (*((w))->mReadDocFile) (w)
#define METHOD_WriteDocResourceFork(w) (*((w))->mWriteDocResourceFork) (w)

#define METHOD_Draw(w, r, s) (*((w))->mDraw) (w, r, s)
#define METHOD_Activate(w) (*((w))->mActivate) (w)
#define METHOD_Deactivate(w) (*((w))->mDeactivate) (w)
#define METHOD_DoContent(w,e) (*((w))->mDoContent) (w, e)
#define METHOD_DoIdle(w) (*((w))->mDoIdle) (w)
#define METHOD_DoDocMenuCommand(w,i,j,k) (*((w))->mDoDocMenuCommand) (w,i,j,k)
#define METHOD_DoPageSetup(w) (*((w))->mDoPageSetup) (w)
#define METHOD_DoPrint(w) (*((w))->mDoPrint) (w)
#define METHOD_DoResize(w,f) (*((w))->mDoResize) (w,f)
#define METHOD_GetHorizLineScrollAmount(w) (*((w))->mGetHorizLineScrollAmount) (w)
#define METHOD_GetVertLineScrollAmount(w) (*((w))->mGetVertLineScrollAmount) (w)
#define METHOD_GetHorizPageScrollAmount(w) (*((w))->mGetHorizPageScrollAmount) (w)
#define METHOD_GetVertPageScrollAmount(w) (*((w))->mGetVertPageScrollAmount) (w)
#define METHOD_AdjustScrollBars(w) (*((w))->mAdjustScrollBars) (w)
#define METHOD_ScrollContents(w,h,v) (*((w))->mScrollContents) (w, h, v)
#define METHOD_FocusOnContent(w) (*((w))->mFocusOnContent) (w)
#define METHOD_FocusOnDocument(w) (*((w))->mFocusOnDocument) (w)
#define METHOD_DisplaySelection(w) (*((w))->mDisplaySelection) (w)
#define METHOD_GetContentRect(w,r) (*((w))->mGetContentRect) (w,r) 
#define METHOD_GetVertSize(w) (*((w))->mGetVertSize) (w)
#define METHOD_GetHorizSize(w) (*((w))->mGetHorizSize) (w)
#define METHOD_DoKeyDown(w,e) (*((w))->mDoKeyDown) (w, e)
#define METHOD_DoCut(w) (*((w))->mDoCut) (w)
#define METHOD_DoCopy(w) (*((w))->mDoCopy) (w)
#define METHOD_DoPaste(w) (*((w))->mDoPaste) (w)
#define METHOD_DoUndo(w) (*((w))->mDoUndo) (w)
#define METHOD_DoClear(w) (*((w))->mDoClear) (w)
#define METHOD_DoSelectAll(w) (*((w))->mDoSelectAll) (w)
#define METHOD_DoConvertKey(w,e) (*((w))->mConvertKey) (w, e)
#define METHOD_AdjustCursor(w,p) (*((w))->mAdjustCursor) (w,p)
#define METHOD_AdjustDocMenus(w, s ) (*((w))->mAdjustDocMenus) (w, s)


/****************************************************************************
**
**  function prototypes
*/

void InitEditor ();
void ProcessEvent ();
DocumentPtr GetEmptyDocument();
short CountDocuments ();

Boolean EqualFSSpec (FSSpec *, FSSpec *);
DocumentPtr FindDocumentFromFSSpec (FSSpec *, OSType);

void DoQuit (Boolean);  /*BH: Boolean canCancel inserted */

void SetDocWindowTitle (DocumentPtr, Str255);
void AdjustMenus(DocumentPtr, short);
void ShowDocWindow (DocumentPtr);
void SizeScrollBars (DocumentPtr);
void DoUpdate (DocumentPtr);
void Scroll (DocumentPtr, ControlHandle, short);
Boolean DoSave (DocumentPtr);
Boolean DoSaveAs(DocumentPtr);
Boolean DoClose (DocumentPtr, Boolean);  /*BH: canCancel inserted */

void CloseDocFile (DocumentPtr);

void SetModDate(FSSpec *, unsigned long);
unsigned long GetModDate(FSSpec *);

void doDiagnosticMessage (short, short);
Boolean doConfirmDialog(short, Str255);
void GetUserAttention (void);

void FatalError(void);

void UpdateList (ListHandle);

Boolean MissedAnyParameters(const AppleEvent *message);

#if MARKS
void sortMarks (DocumentPtr, Boolean);
void FillMarkMenu (DocumentPtr);
MarkRecPtr GetIndMark (Ptr, short);
void UpdateMarks (DocumentPtr,long,long,long,long);
void InsertMark (DocumentPtr,long,long,char *);
void DoUnmark (DocumentPtr,long,long);
#endif

#if PREFERENCES
void GetOptions (Boolean);
#endif

#if BEACHBALL
int SpinACurs (int countNumber);
void ShowACurs (void);
void HideACurs (void);
int InitACurs (int id);
void SuspendACurs (void);
int ACursGoing (void);
#endif


/****************************************************************************
**
**  calback function prototypes
*/
pascal Boolean listFilter (DialogPtr,EventRecord *,short *);
pascal void doLine (DialogPtr,short);
pascal void doButton (DialogPtr,short);
pascal void doFrame (DialogPtr,short);

pascal OSErr AEOpenHandler (const AppleEvent *, AppleEvent *, unsigned long);   /*BH: const, unsigned inserted */
pascal OSErr AEOpenDocHandler (const AppleEvent *, AppleEvent *, unsigned long);   /*BH: const, unsigned inserted */
pascal OSErr AEPrintHandler (const AppleEvent *, AppleEvent *, unsigned long);   /*BH: const, unsigned inserted */
pascal OSErr AEQuitHandler (const AppleEvent *, AppleEvent *, unsigned long);  /*BH: const, unsigned inserted */


/*------------------------------ Macros ---------------------------------*/

#define sizeofMark(m) (9+((MarkRecPtr)(m))->label)
/* #define setDocName(doc,str) BlockMove(str,(doc)->fileSpecs.name,*str+1) */
/*#define pascstr(str) (*((str)+*(str)='\0',(str)+1)*/
/* #define isfullpath(str) (*(str)!=':' && strchr((str)+1,':')) */
#define DialogStandardFilter DialogStandardKeyDown


#define SETMENUABILITY(m,i,b) (b)?EnableItem(m,i):DisableItem(m,i)
#define RECTWIDTH(r) ((r).right-(r).left)
#define RECTHEIGHT(r) ((r).bottom-(r).top)

#define ASSERT(condition) ((condition) ? ((void) 0) : __std(__assertion_failed)(#condition, __FILE__, __LINE__))

#if MARKS
void FillMarkMenu (DocumentPtr);
#endif



/****************************************************************************
**
**  global variables
*/
extern MenuHandle DeskMenu;
extern MenuHandle FileMenu;
extern MenuHandle EditMenu;
extern MenuHandle FindMenu;
extern MenuHandle HelpMenu;

#if MARKS
extern MenuHandle MarkMenu;
#endif

#ifdef GAPVER
extern MenuHandle WindowMenu;
#endif

extern Str255 gFindBuffer ;
extern Str255 gReplaceBuffer ;
extern Str255 gUppercaseTable;

#define UPPERCASE(c) gUppercaseTable[(unsigned char)c]

extern Handle PTScratch;

extern Boolean gHasDrag;


extern short gEditorResRefNum; /* resource file ref num of application */

extern short gSearchMethod;
extern Boolean gSearchBackwards;
extern Boolean gCaseSensitive;
extern Boolean gWrapSearch;
extern long gPrintBufferSize;

extern DocumentRecord Documents[];

extern DocumentPtr gClipboardDoc;

extern CTabHandle MyCMHandle;
extern PaletteHandle DefaultPalette;

extern Rect gDefaultDocRect;

extern short NumFileTypes;
extern SFTypeList MyFileTypes;

extern Boolean gHasColorQD;
extern Boolean gMacPlusKBD;
extern Boolean gHasTranslationMgr;
extern Boolean gInBackground;
extern Boolean gError;
extern Boolean gDAonTop;
extern short gLastScrapCount;
/* OSType gClipType; */
extern FSSpec DefaultSpecs;
extern FSSpec HomeSpecs;

/* to pass values to callback functions */
extern EventRecord *gCurrentEvent;
extern DocumentPtr gCurrentDocument;
extern short gCurrentControlValue, gCurrentScrollAmount;

/* UPPs for PowerMac */

extern ModalFilterUPP SimpleDialogFilterUPP, DialogStandardFilterUPP, formatFilterUPP;
extern ControlActionUPP myControlActionUPP;
extern UserItemUPP doLineUPP, doButtonUPP, doFrameUPP;

/* if using temporary memory */
#if TEMPMEM
extern OSErr gMemError;
#endif

/****************************************************************************
**
**  prototypes for some local functions
*/
static Boolean DoSave (DocumentPtr);
static Boolean DoSaveACopy (DocumentPtr);
static Boolean DoRevert (DocumentPtr);

static void CloseDocFile (DocumentPtr);

static Boolean isEditKey (EventRecord *theEvent);


static void DoActivate (EventRecord *);   
static void OSEvent (EventRecord *);
static void DoSuspend (EventRecord *,Boolean);
static void DoResume (EventRecord *,Boolean);
static void DoKey (EventRecord *);
static void DoMouse (EventRecord *);
static void DoHighLevel (EventRecord *);
static void TileWindows (void);
static void StackWindows (void);
DocumentPtr OpenExistingFile(FSSpecPtr, OSType, Boolean);
DocumentPtr OpenExistingFSSpec(FSSpecPtr, Boolean);
void OpenExistingFileDialog (Boolean);

static DocumentPtr FindDocument (WindowPtr);

static Boolean AcceptableFileType (OSType);
static void OpenNewDoc (void);
static void GiveClipToSystem (void);
static void GetClipFromSystem (void);

static void WindowMenuSelect (short);

static void InitAEStuff (void);

