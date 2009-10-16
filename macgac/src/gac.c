/* headers */
#include <MacTypes.h>
#include <AppleEvents.h>
#include <Files.h>
#include <Folders.h>
#include <Processes.h>
#include <StandardFile.h>
#include <Gestalt.h>
#include "gac.h"
#include "macpaths.h"

/* global vars */
struct AEinstalls {    /* BH: moved here */
    AEEventClass theClass;
    AEEventID theEvent;
    AEEventHandlerProcPtr theProc;  /*BH: changed EventHandlerProcPtr to AEEventHandlerProcPtr */
	AEEventHandlerUPP theUPP;   /* BH: inserted for PowerMac */
} HandlersToInstall[] =  /* BH: handler UPPs must be global (?) */
		{ 	{ kCoreEventClass, kAEOpenApplication, AEOpenHandler, (AEEventHandlerUPP)0	},
			{ kCoreEventClass, kAEOpenDocuments, AEOpenDocHandler, (AEEventHandlerUPP)0	},
			{ kCoreEventClass, kAEQuitApplication, AEQuitHandler, (AEEventHandlerUPP)0	},
			{ kCoreEventClass, kAEPrintDocuments, AEPrintHandler, (AEEventHandlerUPP)0	}
			/* The above are the four required AppleEvents. */
    	};

SFTypeList MyFileTypes = {'TEXT', 0 ,0, 0 };

MenuHandle DeskMenu;              /* handles for menus */
MenuHandle FileMenu;
MenuHandle EditMenu;
Boolean gRunning = true;
Boolean gMakeStatic = false;
Boolean gStop = false;
FSSpec rootFSSpec, GAPFSSpec;
short PrefVRefNum;
long PrefParID;

char rootpath[1024];
unsigned char filesProcessed[1024][32];
long numProcessed = 0;

unsigned char architecture[] = "\p/bin/PPC-motorola-macos-mwerksc/compiled/";

/* Apple event handlers */
pascal OSErr AEOpenHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
#pragma unused (messagein,reply,refIn)
    return noErr;
}

OSErr MissedAnyParameters(const AppleEvent *message)
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
        err = errAEEventNotHandled;
    } else if (err == errAEDescNotFound) {
        err = noErr;
    }
    return err;
}


pascal OSErr AEOpenDocHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
#pragma unused (refIn,reply)
	OSErr err;
    AEDesc theDesc;
    FSSpec theFSS;
    register i;
    long numFilesToOpen;
    AEKeyword ignoredKeyWord;
    DescType ignoredType;
    Size ignoredSize;
	
	if (noErr == (err = AEGetParamDesc(messagein, keyDirectObject, typeAEList, &theDesc))) {
		if (noErr == (err = MissedAnyParameters(messagein))) {
               
			if (noErr == (err = AECountItems(&theDesc, &numFilesToOpen))) {
				for (i = 1; ((i <= numFilesToOpen) && (!err) && !gStop); ++i) {
					if (noErr == (err = AEGetNthPtr(&theDesc, i, typeFSS, &ignoredKeyWord, &ignoredType, (Ptr)&theFSS, 
							sizeof(theFSS), &ignoredSize))) 
						DoCompile(&theFSS, true);
				}
			}												/* for i = ... */
		}													/* AECountItems OK */
	}														/* Got all necessary parameters */
    
	err = AEDisposeDesc(&theDesc);
	return err;
}

pascal OSErr AEPrintHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{                                                           /* no printing handler in yet, so we'll ignore this */
	
#pragma unused (messagein,refIn,reply)
   
   	ParamText ("\pSorry, GAC cannot print files", 0, 0, 0);
	NoteAlert (128, (ModalFilterUPP)0);
	return noErr;
}

pascal OSErr AEQuitHandler(const AppleEvent *messagein, AppleEvent *reply, unsigned long refIn)
{
#pragma unused (messagein,refIn,reply)
    gRunning = false;
    return noErr;
}

/* utility functions */
Boolean FindProcess (ProcessSerialNumber *process,
	FSSpecPtr theFSSpecPtr)
{
	ProcessInfoRec theProcInfo;
	FSSpec processFSSpec;
	
	process->highLongOfPSN = 0;
	process->lowLongOfPSN = kNoProcess; 	// start from the beginning
	theProcInfo.processAppSpec = &processFSSpec;
	theProcInfo.processName = 0;
	
	theProcInfo.processInfoLength = sizeof(ProcessInfoRec);

	while (!GetNextProcess(process)) {

		if ( !GetProcessInformation(process, &theProcInfo) ) {
			if ( (theProcInfo.processType == (long) 'APPL') 
				&& (theProcInfo.processAppSpec->vRefNum == theFSSpecPtr->vRefNum)
				&& (theProcInfo.processAppSpec->parID == theFSSpecPtr->parID)
				&& (EqualString (theProcInfo.processAppSpec->name, 
								theFSSpecPtr->name, false, true)))
				return true;		/* found the process */

		}
	} 

	return false;
}

/* ExecuteGAP tries to compile a file with GAP 
  in is the (GAP root relative) path to the input file
  out is the (GAP root relative) path to the input file, note that ".c" is always appended to out
  init is the name of the init procedure to be called, it will be preceded by "Init__"
  name is used by GAP to identify the module, this should be the same as in
*/

OSErr ExecuteGAP (ConstStr255Param out, ConstStr255Param in, ConstStr255Param init, ConstStr255Param name)
{
	FSSpec 					optionsFSSpec, paramsFSSpec;
    int 					i;
    short 					optionsfref,paramsfref;
    char 					buffer[1024] ;
    long 					icount, ocount;
	LaunchParamBlockRec		myLaunchParams;
 	ProcessSerialNumber 	PSN;
    OSErr 					errno,err2;
    /* separate name of launched program from parameters and options */
	
	if (FindProcess (&PSN, &GAPFSSpec)) {
		ParamText (GAPFSSpec.name,"\pis already running. ",
			"\pPlease quit it and try again",0);
		NoteAlert (128, (ModalFilterUPP)0);
		return -9999;
	}
	errno = FSMakeFSSpec (PrefVRefNum, PrefParID, "\pGAP options",&optionsFSSpec);
	if (errno == fnfErr) {
		errno = FSpCreate (&optionsFSSpec, 'ttxt', 'TEXT', -1); /* make it a SimpleText document */
		}
	if (errno)
		return errno;
	if (errno = FSpOpenDF (&optionsFSSpec, fsWrPerm, &optionsfref))
		return errno;
	SetEOF (optionsfref,0);
	
	/* copy contents of file paramsFSSpec to optionsFSSpec */
	if (!(errno = FSMakeFSSpec (0, 0, "\pgac.options",&paramsFSSpec))) {
		if (!(errno=FSpOpenDF (&paramsFSSpec, fsRdPerm, &paramsfref))) {
			do {
				icount = sizeof (buffer);
				errno = FSRead (paramsfref, &icount, buffer);
				ocount = icount;
				if (icount) 
					errno = FSWrite (optionsfref, &ocount, buffer);				
			} while (!errno && icount ==  sizeof (buffer));
			err2 = FSClose (paramsfref);
		}
		if (errno) 
			return errno;
	}
	ocount = 4;
	if (errno = FSWrite (optionsfref, &ocount, " -C "))
		return errno;
	ocount = out[0];
	/* output file */
	if (errno = FSWrite (optionsfref, &ocount, out+1))
		return errno;
	ocount = 3;
	if (errno = FSWrite (optionsfref, &ocount, ".c "))
		return errno;
	/* input file */
	ocount = in[0];
	if (errno = FSWrite (optionsfref, &ocount, in+1))
		return errno;
	/* name of init proc */
	ocount = 6;
	if (errno = FSWrite (optionsfref, &ocount, " Init_"))
		return errno;
	ocount = icount = filesProcessed[numProcessed][0] 
		= init[0] > sizeof(filesProcessed[numProcessed])? sizeof(filesProcessed[numProcessed]): init[0];
	BlockMove (init+1, filesProcessed[numProcessed]+1,ocount);
	while (icount > 0) {
		if (filesProcessed[numProcessed][icount]=='.')
			filesProcessed[numProcessed][icount]='_';
		icount--;
	}
	if (errno = FSWrite (optionsfref, &ocount, filesProcessed[numProcessed]+1))
		return errno;
	ocount = 1;
	if (errno = FSWrite (optionsfref, &ocount, " "))
		return errno;
	ocount = name[0];
	if (errno = FSWrite (optionsfref, &ocount, name+1))
		return errno;
	if (errno = FSClose (optionsfref))
		return errno; 
	myLaunchParams.launchBlockID = extendedBlock;
	myLaunchParams.launchEPBLength = extendedBlockLen;
	myLaunchParams.launchFileFlags = 0;
	myLaunchParams.launchControlFlags = launchContinue | launchNoFileFlags | launchUseMinimum;
	myLaunchParams.launchAppSpec = &GAPFSSpec;
	myLaunchParams.launchAppParameters = nil;
	if (errno = LaunchApplication(&myLaunchParams))
		return errno;
	while (FindProcess (&PSN, &GAPFSSpec)) /* wait for GAP to quit */
		DoEvent (true);
	errno = FSpDelete (&optionsFSSpec);
	return errno;
}

OSErr ExecuteMake ()
{
	FSSpec 					makeFSSpec;
	LaunchParamBlockRec		myLaunchParams;
 	ProcessSerialNumber 	PSN;
    OSErr 					errno;
    /* separate name of launched program from parameters and options */
	FSMakeFSSpec (0, 0, "\pmake module", &makeFSSpec);

	if (FindProcess (&PSN, &makeFSSpec)) {
		ParamText (makeFSSpec.name,"\pis already running. ",
			"\pPlease quit it and try again",0);
		NoteAlert (128, (ModalFilterUPP)0);
		return -9999;
	}
	myLaunchParams.launchBlockID = extendedBlock;
	myLaunchParams.launchEPBLength = extendedBlockLen;
	myLaunchParams.launchFileFlags = 0;
	myLaunchParams.launchControlFlags = launchContinue + launchNoFileFlags;
	myLaunchParams.launchAppSpec = &makeFSSpec;
	myLaunchParams.launchAppParameters = nil;
	if (errno = LaunchApplication(&myLaunchParams))
		return errno;
	while (FindProcess (&PSN, &makeFSSpec)) /* wait for make shlib to quit */
		DoEvent (true);
	return noErr;
}

OSErr FSpMoveFile (FSSpecPtr srcFSSpecPtr, FSSpecPtr destFSSpecPtr, Boolean replacing)
{
	FSSpec tempFSSpec, tempDir;
	OSErr err;
	
	err = FSMakeFSSpec (srcFSSpecPtr->vRefNum, srcFSSpecPtr->parID, destFSSpecPtr->name, &tempFSSpec);
	if (!EqualString (srcFSSpecPtr->name, destFSSpecPtr->name, false, true)) {
		if (err ==noErr)
			if (replacing)
				FSpDelete (&tempFSSpec);
			else
				return dupFNErr;
		if (err = FSpRename (srcFSSpecPtr, destFSSpecPtr->name))
			return err;
	}
	err = FSMakeFSSpec (destFSSpecPtr->vRefNum, destFSSpecPtr->parID, "\p", &tempDir);
	if (err = FSpCatMove (&tempFSSpec, &tempDir))
		if (err == dupFNErr && replacing) {
			if (err = FSpDelete (destFSSpecPtr))
				return err;
			err = FSpCatMove (&tempFSSpec, &tempDir);
		}
	return err;
}
	
void MakeInitName (ConstStr255Param fname, StringPtr buffer, int size)
/* this is supposed to create the same name string as 'Emit' in compiler.c */
{
	unsigned char *p, c, *hex = (unsigned char*) "0123456789ABCDEF";
	int len, i;
	
	len = fname[0];
	size -= len + 7;
	*buffer = '\0';  /* if anything fails, return the null string */
	if (size < 0) {
		return;
	}
	p = buffer + 7;
	
	for (i=1; i <= len; i++) { /* leave characters and numbers unchanged */
		c = fname[i];
		if (	('0' <= c && '9' >= c) ||
				('A' <= c && 'Z' >= c) ||
				('a' <= c && 'z' >= c) ||
				(c == '/')) 
			*p++ = c;
		else if (c == '_') { /* double underscores */
			*p++ = c;
			*p++ = c;
			if (--size < 0)
			return;
		}
		else {
			size -= 2;
			if (size < 0)
				return;
			*p++ = '_';
			*p++ = hex[c/16];
			*p++ = hex[c%16];
		}
	}	
	BlockMove ("Init__", buffer+1, 6);
	*buffer = p-buffer-1;
	return;
}

	
/* Event handlers */
void DoCompile (FSSpec * theFile, Boolean dynamically)
{
	char buffer[1024], src[256], shlb[1024];
	Str31 name;
	int len, start, bstart, i, dot, fnam;
	OSErr err, err2;
	FSSpec srcFSSpec, destFSSpec, makeFSSpec, optionsFSSpec, oldoptionsFSSpec;
	Boolean renamed = false;
	StandardFileReply reply;
	
	if (err = FSSpecToPath (theFile, buffer+1, sizeof (buffer) - 1, true, false))
		return;
	len = 0;
	while (rootpath[len] && buffer[len+1]==rootpath[len])
		len++;
	if (rootpath[len] || buffer[len+1] != '/')
		bstart = 0; /* absolute path */
	else
		bstart = len+1; /* relaitve path */
	while (buffer[++len])
		;
	if (len - bstart <= 256) 
		buffer[bstart] = (unsigned char)(len - bstart-1);
	else
		return;
	if (dynamically) {
		
		/* get the C source file name */
		err = FSMakeFSSpec (0,0,"\pmodule.c", &srcFSSpec);

		err2 = FSSpecToPath (&srcFSSpec, src+1, sizeof (src) - 1, true, true);
			
		if (err == noErr)
		/* delete module.c, to make sure GAP created a new one */
			err = FSpDelete (&srcFSSpec);
		else if (err == fnfErr)
			err = noErr;
			
		if (err2)
			err = err2;
		if (err) {
			ParamText ("\pError creating file module.c in GAC folder:", 0,0,0);
			NoteAlert (128, (ModalFilterUPP)0);
		}
			
		/* prepare path to c src file for GAP */
		len = 0;
		while (rootpath[len] && src[len+1]==rootpath[len])
			len++;
		if (rootpath[len] || src[len+1] != '/')
			start = 0; /* absolute path */
		else
			start = len+1; /* relaitve path */
		while (src[++len])
			;
		len -= 2; /* remove the ".c" suffix */
		if (len < 0 || len - start >= 256) 
			return; /* file name too long */
			
		src[start] = (unsigned char)(len - start-1);

		if (!(err = FSMakeFSSpec (PrefVRefNum, PrefParID, "\pGAP options", &optionsFSSpec))) {
			err = FSMakeFSSpec (PrefVRefNum, PrefParID, "\pGAP options.bak", &oldoptionsFSSpec);
			if (err == noErr)
				err = FSpDelete (&oldoptionsFSSpec);
			renamed = noErr == (err = FSpRename ( &optionsFSSpec, oldoptionsFSSpec.name));
		}
		
	if (dynamically)
		err2 = ExecuteGAP ((unsigned char*)src+start, (unsigned char*)buffer+bstart, "\pModule", 
				(unsigned char*)buffer+bstart);
		}
	else 
		err2 = ExecuteGAP ((unsigned char*)buffer+bstart, (unsigned char*)buffer+bstart, theFile->name, 
			(unsigned char*)buffer+bstart);
			

	if (renamed) {
		err = FSMakeFSSpec (PrefVRefNum, PrefParID, "\pGAP options", &optionsFSSpec);
		if (err == noErr) {
			FSpDelete (&optionsFSSpec);
		}
		err = FSMakeFSSpec (PrefVRefNum, PrefParID, "\pGAP options.bak", &oldoptionsFSSpec);
		if (err == noErr) 
			err = FSpRename (&oldoptionsFSSpec, "\pGAP options");
		if (err) {
			ParamText ("\pCound not restore file","\pGAP options", "\pin preferences folder", 0);
			NoteAlert (128, (ModalFilterUPP)0);
		}
	}
	if (err2) {
		ParamText ("\pError compiling:", theFile->name,"\ppath", (unsigned char*)buffer+bstart);
		NoteAlert (128, (ModalFilterUPP)0);
		return;
	}
	if (dynamically) { /* now compile and link the shared library */
		/* get fsspec for compiled library and delete old copy */
		err = FSMakeFSSpec (0, 0, "\pmodule.shlb", &srcFSSpec);
		if (err == noErr) 
			FSpDelete (&srcFSSpec);
		else if (err != fnfErr)
			return;
			
		if (bstart) {/* GAP relative path of GAP source file */
			/* make name for shared library in the same way as in sysfiles.c */
			BlockMove (rootpath, shlb, bstart-1);
			len = bstart-1;
			
			BlockMove (architecture+1, shlb+len, *architecture);
			len += *architecture;
			
			fnam = bstart+1;
			i = bstart+1;
			while (buffer[i])
				if (buffer[i++] == '/')
					fnam = i;
			/* copy dest. folder name */
			BlockMove (buffer+bstart+1, shlb+len, fnam-bstart-1);
			len += fnam-bstart-1;
			
			dot = fnam;
			while (buffer[dot] && buffer[dot] != '.')
				dot++;
				
			if (buffer[dot] && buffer[dot+1]) {
				i = dot+1;
				while (buffer[i])
					shlb[len++] = buffer[i++];
				shlb[len++]='/';
			}
			BlockMove (buffer+fnam, shlb+len, dot-fnam);
			len += dot-fnam;
			BlockMove (".shlb", shlb+len, 5);
			len += 5;
			shlb[len]='\0';
			err = PathToFSSpec (shlb, &destFSSpec, true, true);
		} else
			err = bdNamErr; /* just pretend there was an error, so the user is being asked where to put the file */
		if (err && err != fnfErr) {
			StandardPutFile ("\pWhere do you want to save the shared library?", "\pmodule.shlb", &reply);
			if (!reply.sfGood)
				return;
			BlockMove (&reply.sfFile, &destFSSpec, sizeof (destFSSpec));
			if (reply.sfReplacing)
				FSpDelete (&destFSSpec);
		}
		err = ExecuteMake ();
		if (!err) {
			err = FSMakeFSSpec (0, 0, "\pmodule.shlb", &srcFSSpec);
			if (err) {
				ParamText ("\pError creating shared lib for:", theFile->name,"\ppath", (unsigned char*)buffer+bstart);
				NoteAlert (128, (ModalFilterUPP)0);
				return;
			}
			if (err = FSpMoveFile (&srcFSSpec, &destFSSpec, true)) {
				ParamText ("\pError moving shared lib for:", theFile->name,"\ppath", (unsigned char*)buffer+bstart);
				NoteAlert (128, (ModalFilterUPP)0);
				return;
			}
			/* transfer xSYM file if it exists (for debugging) */
			err = FSMakeFSSpec (0, 0, "\pmodule.shlb.xSYM", &srcFSSpec);
			BlockMove (destFSSpec.name, name, destFSSpec.name[0]+1);
			if (err == fnfErr || name[0]>31-5)
				return;
			BlockMove (".xSYM", name+name[0]+1, 5);
			name[0] += 5;
			err = FSMakeFSSpec (destFSSpec.vRefNum, destFSSpec.parID, name, &destFSSpec);
			if (err == noErr) 
				FSpDelete (&destFSSpec);
			else if (err != fnfErr)
				return;
			err = FSpMoveFile (&srcFSSpec, &destFSSpec, true);
			/* now transfer c source file (also needed for debugging) */
			err = FSMakeFSSpec (0, 0, "\pmodule.c", &srcFSSpec);
			if (err)
				return;
			name[0]-=10-2; /* remove ".shlb.xSYM from file name, add ".c" */
			name[name[0]] = 'c';
			err = FSMakeFSSpec (destFSSpec.vRefNum, destFSSpec.parID, name, &destFSSpec);
			if (err == noErr) 
				FSpDelete (&destFSSpec);
			else if (err != fnfErr)
				return;
			err = FSpMoveFile (&srcFSSpec, &destFSSpec, true);
		}
	} else 
		numProcessed++; /* add file name for inclusion in compstat.c */

}

OSErr DoWriteCompstat (void)
{
	unsigned char buffer[1024], *p,*q;
	FSSpec compstatFSSpec, oldFSSpec;
	StandardFileReply reply;
	OSErr err;
	short compstatRef; 
	long iocount;
	int i;
	
	/* make path name for compstat.c */
	p = (unsigned char*) rootpath;
	q = buffer;
	while (*p && q < buffer+sizeof (buffer)) 
		*q++=*p++;
	p=(unsigned char*)"/src/compstat.c";
	while (*p && q < buffer+sizeof (buffer)) 
		*q++=*p++;
	if (q >= buffer+sizeof (buffer)) 
		return bdNamErr;
	*q = '\0';
	/* see if compstat.c exists and take appropriate action */

	err = PathToFSSpec ((char*)buffer, &compstatFSSpec, true, false);
	if (err == noErr) {/* file exists */
		ParamText ("\pfile compstat.c already exists. Replace it?", "\p(old file will be renamed to",
			"\pcompstat.c.bak)", 0);
		if (CautionAlert (129, (ModalFilterUPP)0) == ok) 
			err = FSpRename (&compstatFSSpec, "\pcompstat.c.bak");			
		else {
			StandardPutFile("\pSave initialisation file as","\pcompstat.c",&reply);
			if (!reply.sfGood)					
				return noErr;
			BlockMove (&reply.sfFile, &compstatFSSpec, sizeof (compstatFSSpec));
		}
	} else if (err != fnfErr)
		return err;
	/* try to create output file */
	err = FSpCreate (&compstatFSSpec, 'CWIE', 'TEXT', 0);
	if (err && err != dupFNErr)
		return err;
	/* now open the file and write data - we reuse buffer */
	if (err = FSpOpenDF (&compstatFSSpec, fsWrPerm, &compstatRef))
		return err;
	p = "\p/* made by 'gac', can be thrown away */\r\
		#include \"system.h\"\r\
		#include \"compiled.h\"\r\r";
	iocount = p[0]; 
	err = FSWrite (compstatRef, &iocount, p+1);
	if (err || iocount != p[0])
		return err;
    for (i=0; i< numProcessed; i++) {
       	p = "\pextern StructInitInfo * ";
		iocount = p[0]; 
		err = FSWrite (compstatRef, &iocount, p+1);
		if (err || iocount != p[0])
			return err;
		MakeInitName (filesProcessed[i], buffer, sizeof (buffer));
		iocount = buffer[0]; 
		err = FSWrite (compstatRef,  &iocount, buffer+1);
		if (err || iocount != buffer[0])
			return err;
       	p = "\p ( void );\r";
		iocount = p[0]; 
		err = FSWrite (compstatRef, &iocount, p+1);
		if (err || iocount != p[0])
			return err;
    }       	
    p = "\p\rInitInfoFunc CompInitFuncs [] = {\r	";
	iocount = p[0]; 
	err = FSWrite (compstatRef, &iocount, p+1);
	if (err || iocount != p[0])
		return err;
    for (i=0; i< numProcessed; i++) {
		MakeInitName (filesProcessed[i], buffer, sizeof (buffer));
		iocount = buffer[0]; 
		err = FSWrite (compstatRef, &iocount, buffer+1);
		if (err || iocount != buffer[0])
			return err;
       	p = "\p,\r	";
		iocount = p[0]; 
		err = FSWrite (compstatRef, &iocount, p+1);
		if (err || iocount != p[0])
			return err;
    }       	
    p = "\p0};\r";
	iocount = p[0]; 
	err = FSWrite (compstatRef, &iocount, p+1);
	if (err || iocount != p[0])
		return err;
	err = FSClose (compstatRef);
	return err;
}

void DoMenu (long menuResult)
{
	StandardFileReply reply;
	
	if (HiWord(menuResult) == iFileMenu) {
		switch (LoWord (menuResult)) {
			case iMakeStatic:
				gMakeStatic = !gMakeStatic;
				break;
			case iCompile:
				StandardGetFile(0,1,MyFileTypes,&reply);
				if (reply.sfGood)
					DoCompile (&reply.sfFile, !gMakeStatic);
				break;
			case iStop:
				ParamText ("\pPress 'OK' to stop compiling","\p after the current file has been processed.",0,0);
				if (CautionAlert (129, (ModalFilterUPP)0) == ok) 
					gStop = true;
				break;
			case iQuit:
				gRunning = false;
				break;
		}
	}
}

void DoEvent (Boolean busy)
{	
	EventRecord theEvent;
	Boolean gotEvent;
	WindowPtr wind;
    Str31 num;
	OSErr err;
	short mask;
	long response, sleep;
	
	CheckItem (FileMenu, iMakeStatic, gMakeStatic);
	mask = everyEvent;
	
	if (busy) {
		DisableItem (FileMenu, iMakeStatic);
		DisableItem (FileMenu, iCompile);
		if (gStop)
			DisableItem (FileMenu, iStop);
		else
			EnableItem (FileMenu, iStop);
		mask = mask & ~highLevelEventMask;
		sleep = 60;
	} else {
		EnableItem (FileMenu, iMakeStatic);
		EnableItem (FileMenu, iCompile);
		DisableItem (FileMenu, iStop);
		sleep = -1;
		gStop = false;
	}
	
	gotEvent=WaitNextEvent(mask,&theEvent, sleep, (RgnHandle)0);

	if(gotEvent) {
		switch(theEvent.what) {
			//case osEvt:
			case mouseDown:
				if (FindWindow(theEvent.where,&wind)==inMenuBar) {
					response = MenuSelect(theEvent.where);
					DoMenu (response);
					HiliteMenu (0);
				}
				break;
			case keyDown:
			case autoKey:
				if (theEvent.modifiers&cmdKey) {
					response = MenuKey ((short)theEvent.message&charCodeMask);
					DoMenu (response);
				}
				break;
			case activateEvt:
			case updateEvt:
				DrawMenuBar();
				break;
			//case nullEvent:
			case kHighLevelEvent:
                err = AEProcessAppleEvent(&theEvent);
                if (err != noErr) {
					NumToString (err, num);
					ParamText ("\pError processing Apple Evemt","\pError code", num, 0);
					NoteAlert (128, (ModalFilterUPP)0);
				}
			default:
				break;
		}
	} 
}
/* main */
void main ()
{
    Str31 num;
	OSErr err;
	long response, i;
	StringHandle GAPname;
	Boolean isFolder, wasAliased;
	
    InitGraf(&qd.thePort);
	InitFonts();
	FlushEvents(everyEvent,0);
	InitWindows();
	InitMenus();
	InitDialogs(0); /*BH: changed ResumeProcPtr(restartProc) to 0 */
	InitCursor();
	DeskMenu=GetMenu(iAppleMenu);
	AppendResMenu(DeskMenu,'DRVR');
	InsertMenu(DeskMenu,0);
	FileMenu=GetMenu(iFileMenu);
	InsertMenu(FileMenu,0);
	EditMenu=GetMenu(iEditMenu);
	InsertMenu(EditMenu,0);
	DrawMenuBar();
	
 	if (Gestalt(gestaltAliasMgrAttr,&response)) {
		ParamText ("\pGAC requires the Alias Manager.",
			"\p(This is a standard component in System 7 and above.)", 0,0);
		NoteAlert (128, (ModalFilterUPP)0);
		ExitToShell();			
 	}
 	err = FSMakeFSSpec (0, 0, "\pGAP folder", &rootFSSpec);
	if (!err)
		err = ResolveAliasFile (&rootFSSpec, true, &isFolder, &wasAliased);
	if (err) {
		NumToString (err, num);
		ParamText ("\pError finding GAP folder ‹ Try puttiang",
			"\pan alias called \"GAP folder\" into your GAC folder","\pError code", num);
		NoteAlert (128, (ModalFilterUPP)0);
		ExitToShell();			
	}
	err = FSMakeFSSpec (0, 0, "\pGAP", &GAPFSSpec);
	if (!err) 
		err = ResolveAliasFile (&GAPFSSpec, true, &isFolder, &wasAliased);
	if (err) {
		NumToString (err, num);
		ParamText ("\pError finding GAP application ‹ Try puttiang",
			"\p an alias called \"GAP\" into your GAC folder","\pError code", num);
		NoteAlert (128, (ModalFilterUPP)0);
		ExitToShell();			
	}
		
	err = FindFolder (kOnSystemDisk, kPreferencesFolderType, kCreateFolder, &PrefVRefNum, &PrefParID);
	if (err) {
		NumToString (err, num);
		ParamText ("\pError finding Preferences folder (in the System folder)",
			"\pError code", num, 0);
		NoteAlert (128, (ModalFilterUPP)0);
		ExitToShell();			
	}
	err = FSSpecToPath (&rootFSSpec, rootpath, sizeof (rootpath), true, false);
	if (err) {
		NumToString (err, num);
		ParamText ("\pError creating full Unix root path name","\pError code", num, 0);
		NoteAlert (128, (ModalFilterUPP)0);
		ExitToShell();		
	}
	
	if(Gestalt(gestaltAppleEventsAttr,&response)==noErr) {
		for (i = 0; i < ((sizeof(HandlersToInstall) / sizeof(struct AEinstalls))); i++) {
			HandlersToInstall[i].theUPP = NewAEEventHandlerProc (HandlersToInstall[i].theProc);   /* for Power Mac */
			err = AEInstallEventHandler(HandlersToInstall[i].theClass, HandlersToInstall[i].theEvent,
                                           HandlersToInstall[i].theUPP, 0, false);
			if (err) {
				NumToString (err, num);
				ParamText ("\pError installing Apple Evemt","\pError code", num, 0);
				NoteAlert (128, (ModalFilterUPP)0);
				ExitToShell();		
			}
 	   }
	}
	
	while (gRunning) {
		DoEvent (false);
	}
	if (numProcessed) 
		if (noErr != DoWriteCompstat ()) {
			ParamText ("\pError creating file","\pcompstat.c ",0,0);
			NoteAlert (128, (ModalFilterUPP)0);
		}	
}
