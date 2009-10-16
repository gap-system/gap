/****************************************************************************
**
*W  macdocs.h                   GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the window specific method declarations for the built-in text editor.
**  Note that the GAP specific methods are in maccon.h/maccon.c.
*/

/****************************************************************************
**
**  prototypes for null methods
*/
void nullVoidDocumentMethod (DocumentPtr);
void nullVoidDocumentEventMethod (DocumentPtr,EventRecord *);
void nullVoidDocumentPointMethod (DocumentPtr,Point);
void nullVoidDocumenBoolMethod (DocumentPtr, Boolean);
long nullLongDocumentMethod (DocumentPtr);
short nullShortDocumentMethod (DocumentPtr);
Boolean nullBoolDocumentMethod (DocumentPtr);
Boolean nullBoolDocumentEventMethod (DocumentPtr,EventRecord *);
Boolean nullBoolDocumentBoolMethod (DocumentPtr, Boolean, Boolean);

/****************************************************************************
**
**  prototypes for default methods
*/
void defaultFocusOnDocument (DocumentPtr);
void defaultFocusOnContent (DocumentPtr);
void defaultGetContentRect (DocumentPtr, Rect *);
void defaultDraw (DocumentPtr,Rect *, short);
void defaultDoContent (DocumentPtr,EventRecord *);
void defaultAactivate (DocumentPtr);
void defaultDeactivate (DocumentPtr);
void defaultAdjustScrollBars (DocumentPtr);
void defaultScrollContents (DocumentPtr, short, short);
short defaultGetVertPageScrollAmount (DocumentPtr);
short defaultGetHorizPageScrollAmount (DocumentPtr);	
Boolean defaultOpenDocFile (DocumentPtr);
short defaultGetLineScrollAmount (DocumentPtr);
Boolean defaultInitDoc (DocumentPtr);
Boolean defaultDestructor (DocumentPtr);		
void defaultAdjustDocMenus (DocumentPtr, short);
Boolean defaultDoDocMenuCommand (DocumentPtr, short, short, short);

void AddDefaultDocumentMethods (DocumentPtr);

/****************************************************************************
**
**  prototypes for clipboard methods
*/
Boolean clipboardDestructor (DocumentPtr);
void clipboardAdjustDocMenus (DocumentPtr, short);
void clipbooardDoContent (DocumentPtr, EventRecord *);
void clipboardDoIdle (DocumentPtr);

DocumentPtr OpenClipboardWindow (void);
/****************************************************************************
**
**  prototypes for text methods
*/
void textDraw (DocumentPtr, Rect *,short);
void textActivate (DocumentPtr);
void textDeactivate (DocumentPtr);
void textDoIdle (DocumentPtr wind);
void textAdjustCursor (DocumentPtr,Point);
void textDoKeyDown (DocumentPtr,EventRecord *);
void textDoUndo (DocumentPtr);
Boolean textConvertKey (DocumentPtr, EventRecord *);
Boolean textDestructor (DocumentPtr);
short textGetHorizSize (DocumentPtr);
short textGetVertSize (DocumentPtr);
void textGetContentRect (DocumentPtr,Rect *);
void textScrollContents (DocumentPtr,short,short);
short textGetVertLineScrollAmount (DocumentPtr);
short textGetHorizLineScrollAmount (DocumentPtr);
short textGetHorizPageScrollAmount (DocumentPtr);
void textReadOnlyDoKeyDown (DocumentPtr,EventRecord *);
Boolean textDoDocMenuCommand (DocumentPtr, short, short, short);
void textAdjustDocMenus (DocumentPtr, short);
Boolean textReadIntoGAP  (DocumentPtr, Boolean, Boolean);
void textReadOnlyAdjustDocMenus (DocumentPtr, short);

void AddTextDocumentMethods (DocumentPtr);
void AddTextReadOnlyMethods (DocumentPtr);


/****************************************************************************
**
**  calback function prototypes
*/
pascal Boolean DialogStandardKeyDown (DialogPtr, EventRecord *, short *);
pascal Boolean myClicker(void);
pascal Boolean formatFilter (DialogPtr,EventRecord * ,short *);
pascal void myControlActionProc (ControlHandle,short);

/****************************************************************************
**
**  other function prototypes
*/
void DoPageScroll (DocumentPtr, ControlHandle, short);
char *GetSelection (DocumentPtr,char *,long);
short SetSelectionFlag (TE32KHandle tH);
Boolean ReadTextDocResourceFork (DocumentPtr doc);

/****************************************************************************
**
**  prototypes for some local functions
*/
static char *matchExpressionRight(char *, char *,long *, long *);
static Boolean findSearchString (DocumentPtr, short);
static Boolean doFindDialog(short which);
static short doReplaceDialog(void);
static void ScrollClick (DocumentPtr,EventRecord *);
static long DoLineDialog (long, long);
static void EnTabAndShift (DocumentPtr, short);
static void SetTE32KRect (DocumentPtr);
static void doFormatDialog (DocumentPtr);
static void EnTabAndShift(DocumentPtr, short);
static long VirtualEntabALine(StringPtr, long *, long *, long);
static Boolean InitScrollDoc (DocumentPtr);
static void DoThumbScroll (DocumentPtr, ControlHandle,Point);
static void DoButtonScroll(DocumentPtr, ControlHandle,Point );
