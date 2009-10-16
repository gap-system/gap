/* resource IDs */

#define iAppleMenu 128
#define iFileMenu 129
#define iEditMenu 130
#define iCompile 1
#define iMakeStatic 2
#define iStop 3
#define iQuit 5

/* prototypes */
pascal OSErr AEOpenHandler(const AppleEvent *, AppleEvent *, unsigned long);   
pascal OSErr AEOpenDocHandler(const AppleEvent *, AppleEvent *, unsigned long);  
pascal OSErr AEPrintHandler(const AppleEvent *, AppleEvent *, unsigned long); 
pascal OSErr AEQuitHandler(const AppleEvent *, AppleEvent *, unsigned long);
OSErr MissedAnyParameters(const AppleEvent *message);

OSErr FSpMoveFile (FSSpecPtr srcFSSpecPtr, FSSpecPtr destFSSpecPtr, Boolean replacing);
Boolean FindProcess (ProcessSerialNumber *process, FSSpecPtr theFSSpecPtr);
OSErr ExecuteGAP (ConstStr255Param out, ConstStr255Param in, ConstStr255Param init, 
	ConstStr255Param name);
OSErr ExecuteMake ();
OSErr DoWriteCompstat (void);
void MakeInitName (ConstStr255Param fname, StringPtr buffer, int size);

void DoCompile (FSSpec * theFile, Boolean dynamically);
void DoMenu (long menuResult);
void DoEvent (Boolean busy);
