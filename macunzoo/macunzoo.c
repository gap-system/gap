/****************************************************************************
**
*W  macunzoo.c                                              Burkhard Hoefling
**
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
*/
#include <AppleEvents.h>
#include <files.h>
#include <gestalt.h>
#include <processes.h>
#include <Sound.h>
#include <stdio.h>
#include <SIOUX.h>
#include <URLAccess.h>

extern int IsActive;

extern int DragAndDropEnabled;

int ExtrArch (unsigned long, unsigned long, unsigned long, char *, char *, unsigned long, char *);


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
        SysBeep(3);
        /* doMessage(7); */
        err = errAEEventNotHandled;
    }
    
    /* errAEDescNotFound means that there are no more parameters. If we get */
    /* an error code other than that, flag it. */
    
    else if (err != errAEDescNotFound) {
        SysBeep(3);
        /* doMessage(8); */
        
    }
    return(err != errAEDescNotFound);
}

pascal OSErr AEOpenDocHandler(const AppleEvent *messagein, 
	AppleEvent *reply, unsigned long refIn)
{
    OSErr err;
    OSErr err2;
    AEDesc theDesc;
    FSSpec theFSS;
    long qq;
    long numFilesToOpen;
    AEKeyword ignoredKeyWord;
    DescType ignoredType;
    Size ignoredSize;
	char path[1024], prefix[1024], *p, *q, *r;
	
	err = AEGetParamDesc(messagein, keyDirectObject, typeAEList, &theDesc);
	if (err) 
		SysBeep(3);
		/* doMessage(9);*/

	if (!MissedAnyParameters(messagein)) {
        
		/* Got all the parameters we need. Now, go through the direct object, */
		/* see what type it is, and parse it up. */
        
		if (err = AECountItems(&theDesc, &numFilesToOpen)) {
			SysBeep(3);
			/* doMessage(10); */
		} else {
			for (qq = 1; ((qq <= numFilesToOpen) && (!err)); ++qq) {
				if (err = AEGetNthPtr(&theDesc, qq, typeFSS, &ignoredKeyWord, &ignoredType, (Ptr)&theFSS, sizeof(theFSS),
						&ignoredSize)) {
					SysBeep(3);
					/* doMessage(11); */
                    
				} else {
					err = FSSpecToPath (&theFSS, &path, sizeof (path), false, false);
					p = path;
					q = prefix;
					r = prefix;
					while (*p) {
						if (*p==':')
							r = q;
						*q++=*p++;
					}
					*r = '\0';

					if (IsActive == 0 && err == noErr) {
						fflush (stdin);
						fputs ("-x -j \"", stdout);
						fputs (prefix, stdout);
						fputs ("\" \"", stdout);
					    fputs (path, stdout);
						fputs ("\"\n", stdout);
					}
					else {
						SysBeep(3);
					}				
				}
			}			/* for qq = ... */
		}				/* AECountItems OK */
	}					/* Got all necessary parameters */
    
	if (err2 = AEDisposeDesc(&theDesc)) 
		SysBeep(3);
		/* doMessage(12); */

	return(err ? err : err2);
}

pascal OSErr AEPrintDocHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
    return noErr;
}

pascal OSErr AEOpenAppHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
    return noErr;
}

pascal OSErr AEQuitHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
    ExitToShell();
}

#if TARGET_CPU_PPC
    Boolean gURLAvailable;
#endif

void InitMacUnzoo ()
{
    
	AEEventHandlerUPP AEOpenAppHandlerUPP, AEQuitHandlerUPP, 
		AEOpenDocHandlerUPP, AEPrintDocHandlerUPP;
	EventRecord theEvent;
	OSErr err;
	char str[79];
	long response;
	
    SIOUXSettings.autocloseonquit = 1;
    SIOUXSettings.asktosaveonclose = 0;
    SIOUXSettings.rows = 30;
	SIOUXSettings.userwindowtitle = "\punzoo";
		
	DragAndDropEnabled = (Gestalt(gestaltAppleEventsAttr,&response)==noErr);

	if (DragAndDropEnabled) {
		AEOpenAppHandlerUPP = NewAEEventHandlerProc (AEOpenAppHandler);  
	
		err = AEInstallEventHandler(kCoreEventClass, kAEOpenApplication, 
			AEOpenAppHandlerUPP, 0, false);
			
		AEOpenDocHandlerUPP = NewAEEventHandlerProc (AEOpenDocHandler);  
		
		err = AEInstallEventHandler(kCoreEventClass, kAEOpenDocuments, 
			AEOpenDocHandlerUPP, 0, false);
	        
		AEPrintDocHandlerUPP = NewAEEventHandlerProc (AEPrintDocHandler);  
		
		err = AEInstallEventHandler(kCoreEventClass, kAEPrintDocuments, 
			AEPrintDocHandlerUPP, 0, false);
	        
		AEQuitHandlerUPP = NewAEEventHandlerProc (AEQuitHandler);  
		
		err = AEInstallEventHandler(kCoreEventClass, kAEQuitApplication, 
			AEQuitHandlerUPP, 0, false);
	}
#if TARGET_CPU_PPC
	gURLAvailable = URLAccessAvailable();
#endif
}

