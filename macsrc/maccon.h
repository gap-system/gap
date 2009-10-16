/****************************************************************************
**
*W  maccon.h                    GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the declaration part of the console-specific functions for GAP, i.e. the 
**  functions regarding log and help windows. Other GAP-specific settings 
**  must be in the files 'macheaders.h'
**  or 'macdefs.h' .
*/
#include "macdefs.h" /* common definitions for C and resource compiler */
#if !TARGET_API_MAC_CARBON
#include <types.h>
#include <files.h>
#endif
/* determine behaviour of console package */

#if HELP_WINDOW
#define NUMRESERVEDWINDS 2  /* reserve log and help document windows */ 
#else
#define NUMRESERVEDWINDS 1  /* reserve log document windows */ 
#endif

#define LOGDOCUMENT Documents[0]

#if HELP_WINDOW
#define HELPDOCUMENT Documents[1]
#endif

#define MEM_FRAGMENT 1  /* load code fragments into memory */

/* prototypes for functions in maccon.c */
#if HELP_WINDOW
Boolean OpenHelpWindow ();
void SetHelpWindowTitle (char *) ;
void WriteToHelp ( char*  );
#endif

Boolean OpenLogWindow ();
void FlushLog ();  /* discard pending input from log */
char * ReadFromLog (char*, long, long );   
void WriteToLog (const char*  );
Boolean ConvertGAPKeys (DocumentPtr, EventRecord *, Boolean);
void GetLogWindowSize ( void );
void SetLogWindowSize ( long rows, long cols );

void TruncateDocument (DocumentPtr theDocument, long limit);

Boolean ExecuteGAPCommand ( char * str);
void GetGAPHelp (char * str);
void DoLogTo (void);

void OpenAboutBox (long);

OSErr DeleteFolderAndContents (short, long);

/* variables for maccon.c */
extern short 			gPreferencesResRefNum;
extern Boolean			gScrollToPrintout;
extern Boolean 			gGAPIsIdle;
extern Boolean 			gUserWantsToQuitGAP;
extern Boolean 			gShowPartialCollection;

extern long 			creditTicks; 

/* constants needed for the GAP preferences dialog */
#if GAPVER == 4
# define OPTDIALOG_ID 129
# define iCmdLine 4
# define iSaveDefault 5
#elif GAPVER == 3
# define OPTDIALOG_ID 128
# define iDefault 3       
# define iSaveDefault 16
# define iMemory 7
# define iMemoryStatic 17
# define iLibname 6
# define iLibnameStatic 18
# define iHelpname 5
# define iHelpnameStatic 19
# define iIntrFreq 14
# define iIntrFreqText 15
# define iGasman 11
# define iGaprc 13
# define iBanner 12
# define iHelpWarnings 4
# define iMaxMemory 20
#endif

#define ABOUT_PICT_ID	128   /* id of PICT resource for About box */

/* type and variable for Mac error messages */

typedef struct errdesc{
	OSErr code;
    char * description;
} errdesc;

extern errdesc 	gMacOSErrDesc[];

extern long 	gEditorScratch;
extern long 	gMaxLogSize;

extern char 	consoleHistory[8192];   
extern char 	* consoleHistoryPtr, * consoleHistoryEnd;  

/* the following should better be in system.h */

#if GAPVER == 3
extern void SyHelp (char*, long);
extern void syHelpHeader (	char* , char* , long );   
extern char syLastTopics [16] [64];
extern short syLastIndex;
#  define GET_GAP_HELP(str)  SyHelp(str, HELPFID)
#elif GAPVER == 4
#  define GET_GAP_HELP(str) GetGAPHelp (str) 
#endif

#if GAPVER == 3
#define LENHELPHISTORY 16  /* from system.c */
#endif

#if HELP_WINDOW && GAPVER == 3
#define HELPFID -2             /* on the Mac, help text goes to a separate window */
#endif                               /* must be in the header because it is needed by the menu handler */

/* the following are needed for the preferences dialog */

#if HELP_WINDOW
extern	long SyHelpWarnings;   /* suppress help warning messages? */
#endif

extern long SyIsInterrupted;   /* Mac interrupt flag */
extern long SyStorLimit;       /* maximum amount of workspace available */
extern long SyRawMode;

#if GAPVER == 3
extern long SyStorMin;	       /* amount of workspace initially allocated */
extern long SyGasman;          /* show garbage collection? */
#endif

extern  FSSpec gGapOptionsFSSpec; /* Apple file descriptor for options file */

#if GAPVER == 3
# define SyCTRD syCTRD
# define SyStorMin SyMemory

/* the following should better be in idents.h */
extern unsigned long   iscomplete ( char *, unsigned long, unsigned long);
extern unsigned long   completion ( char *, unsigned long, unsigned long);

extern long syIsIntrFreq;
extern long syCTRD;
extern int SyGaprc;

#endif

#if GAPVER == 4
void ModifyOptions (char*);
#endif

pascal OSErr AEExecuteGAPCommandHandler(const AppleEvent *messagein, 
	AppleEvent *reply, unsigned long refIn);
pascal OSErr AEGetGAPHelpCommandHandler(const AppleEvent *messagein, 
	AppleEvent *reply, unsigned long refIn);

/****************************************************************************
**
**  prototypes for console methods
*/
Boolean consoleReadIntoGAP (DocumentPtr, Boolean, Boolean);
void consoleDoKeyDown (DocumentPtr, EventRecord *);
void consoleDoUndo (DocumentPtr);
Boolean consoleConvertKey (DocumentPtr, EventRecord *);
Boolean consoleDoDocMenuCommand (DocumentPtr, short, short, short);
void consoleAdjustDocMenus (DocumentPtr, short);

/****************************************************************************
**
**  misc. prototypes
*/
void FlushDocument (DocumentPtr doc) ;  /* discard pending input from document */
