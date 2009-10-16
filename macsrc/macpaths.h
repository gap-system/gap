/****************************************************************************
**
*W  macpaths.h                  GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
** the declarations for macpaths.c
*/
OSErr FSSpecToPath (const FSSpecPtr theFSP, char * thePath, long maxlen, 
	Boolean Unix, Boolean create);

OSErr PathToFSSpec (const char * path, FSSpecPtr theFSP, 
	Boolean isUnix, Boolean create);
