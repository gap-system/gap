/****************************************************************************
**
*W  macpaths.c                  GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  routines for converting Unix or Mac path names into FSSpecs and back, 
**  resolving aliases (aka symbolic links) on their way.
*/
#define RESOLVE_ALIASES 1
#if !TARGET_API_MAC_CARBON
#include <Aliases.h>
#include <Errors.h>
#include <Script.h>
#endif

#include "macpaths.h"

/****************************************************************************
**
**  FSSpecToPath converts the file spec referenced by FSSpecPtr into a path
**  name of length at most maxlen. (Unix style if Unix is true, 
**  otherwise Mac style). If create is true, the file  referenced by FSSpecPtr
**  is created if necessary.
*/
OSErr FSSpecToPath (const FSSpecPtr theFSP, char * thePath, long maxlen, 
	Boolean Unix, Boolean create)
{
	AliasHandle theAlias;

	Str63 buffer;
	long index=0, len, newlen;
	OSErr err;
	char *q;
	Boolean delete = false;

	*thePath = '\0';
	len = 1;

	err = NewAlias (0, theFSP, &theAlias);
	if (err == fnfErr && create) {
		err = FSpCreate (theFSP, '????', '????',smSystemScript);
		if (!err) {
			delete = true;
			err = NewAlias (0, theFSP, &theAlias);
		}
	}
	if (err)
		return err;
	do {
		if (err = GetAliasInfo (theAlias, index++, buffer))
			return err;
		if (*buffer ) {
			newlen = buffer[0];
			len += newlen+1;
			if (len > maxlen)
				return bufferIsSmall;
			/* prepend new part of path */
			BlockMove (thePath, thePath+newlen+1, len-newlen-1);
			BlockMove (buffer + 1, thePath+1, newlen);
			
			/* convert possible slashes in file name */
			if (Unix) {
				q = thePath;
				while (newlen--) {
					if (*(++q) == '/') {
						len += 2;
						if (len > maxlen)
							return bufferIsSmall;
						BlockMove (q, q+2, thePath + len - 2 - q);
						*q++ = '\\';
						*q++ = '\\';
					}
				}
				*thePath = '/';
			}
			else
				*thePath = ':';
		}
	}
	while (*buffer);

	
	if (err = GetAliasInfo (theAlias, asiVolumeName, buffer))
		return err;
	len += buffer[0];
	if (len > maxlen) 
		return bufferIsSmall;
	BlockMove (thePath, thePath+buffer[0], len-buffer[0]);
	BlockMove (buffer+1, thePath, buffer[0]);
	if (Unix) {
		if (len >= maxlen)
			return bufferIsSmall;
		BlockMove (thePath, thePath+1, len);
		*thePath = '/';
	}
	if (delete) {
		err = FSpDelete (theFSP);
		return err;
	}
	else
		return noErr;
}




/****************************************************************************
**
**  PathToFSSpec converts a path name (Unix style if isUnix is true, 
**  otherwise Mac style) into an FSSpec, resolving aliases on its way. If 
**  create is true, folders are created as needed, so that a valid FSSpec 
**  is returned even if the enclosing folder(s) of a nonexisting file did
**  not exist before.
*/

#define DO_TIMING 1
#if DO_TIMING
long time_used = 0;
#endif

OSErr PathToFSSpec (const char * path, FSSpecPtr theFSP, 
	Boolean isUnix, Boolean create)
{
	long i, j;
	Str255 buf;
	OSErr err;
	Boolean isFolder, wasAliased;
	char separator;
	long dirID;

	if (!isUnix)
		return bdNamErr;
		
	if (path == 0 || *path =='\0')
		return bdNamErr;
	
	separator = isUnix ? '/' : ':';

	theFSP->name[0] = 0;
	theFSP->parID = 0;	
	theFSP->vRefNum = 0;
	
	if (*path == separator) {
		path++;
		if (!isUnix) 
			goto relativePath;
	}
	else if (isUnix) 
		goto relativePath;

    /* path is either a filename or an absolute path */	
	j = 0;
	while (*path != '\0' && *path != separator) {
		if (j >= 255 || *path == ':')
			return bdNamErr;
		if (*path == '\\') {
			path++;
			if (*path == ':')
				return bdNamErr;
			else
				buf[++j] = *path++;
		} else
			buf[++j] = *path++;
	};

	if (*path == separator) {   /* if it is start of an absolute path */
		buf[++j] = ':';
	}
	buf[0] = j;
	
	err = FSMakeFSSpec (theFSP->vRefNum, theFSP->parID, buf, theFSP);
#if RESOLVE_ALIASES
	if (!err && *path != separator) 
		err = ResolveAliasFile (theFSP, true, &isFolder, &wasAliased);
#endif
	if (err)
		return err;
		
	if (*path == '\0')   /* if this was a file */
		if (isUnix)
			return bdNamErr;    /* /<name> should always be a directory?! */
		else
			return err;
	path++;
	j = 0;
	goto absolutePath;
	
relativePath: 
	
	do {
	
		/* theFSP->name contains name of parent dir, possibly empty */
		buf[1] = ':';
		j = 1;
		
absolutePath:
		if (theFSP->name[0]) {
			BlockMove (theFSP->name + 1, buf+j+1, theFSP->name[0]);
			j += theFSP->name[0];
			buf[++j] = ':';
		}
		else 
			j = 1;
			
		/* now copy next part of path name */
		
		i = j;
		while (*path != '\0' && *path != separator) {
				if (j >= 255 || *path == ':')
					return bdNamErr;
				if (*path == '\\') {
					path++;
					if (*path == ':')
						return bdNamErr;
					else
						buf[++j] = *path++;
				} else
					buf[++j] = *path++;
			};
			
		/* check for ../ (Unix) or :: (Mac) */
		if ((isUnix && j-i == 2 && path[-1] == '.' && path[-2] == '.')   
			   || (!isUnix && j == i)) {
			j = i;  
			buf[++j] = ':';
		}
		/* check for ./ (Unix) */
		else if ((isUnix && j-i == 1 && path[-1] == '.')) {
			j = i;  /* ignore */
		}
		buf[0] = j;
				
		err = FSMakeFSSpec (theFSP->vRefNum, theFSP->parID, buf, theFSP);
		if (!err) {
#if RESOLVE_ALIASES
			err = ResolveAliasFile (theFSP, true, &isFolder, &wasAliased);
#else
			isFolder = true;
#endif
		}  else if (create && err == fnfErr && *path != '\0')
			err = FSpDirCreate (theFSP, 0, &dirID); /* create folders as we go */
		if (*path == separator)
			path++;
	}
 	while (*path != '\0' && isFolder && err == noErr);
 	
 	if (*path == '\0')
 		return err;
 	else
 		if (err == fnfErr)
			return dirNFErr;
		else
			return bdNamErr;
}
