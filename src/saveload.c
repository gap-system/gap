/****************************************************************************
**
*A  saveload.c                  GAP source                   Steve Linton
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions concerned with saving and loading
**  the workspace. There are support functions in gasman.c and elsewhere
**  throughout the kernel
*/
char *          Revision_saveload_c =
   "@(#)$Id$";

#include        "system.h"             /* UInt ... */
#include        "gasman.h"             /* Bag      */
#include        "objects.h"            /* Obj .... */
#include        "bool.h"               /* True, False */
#include        "calls.h"              /* CALL_1ARGS */
#include        "gap.h"                /* Error */
#include        "gvars.h"               /* GVarName */

#define INCLUDE_DECLARATION_PART
#include        "saveload.h"
#undef  INCLUDE_DECLARATION_PART

/***************************************************************************
**
*F  SaveWorkspace( <fname> ) . . . . . .save the workspace to the named file
**
**  'SaveWorkspace' is the entry point to the workspace saving. It is not
**  installed as a GAP function, but instead as a keyword, so that we can be
**  sure it is only being called from the top-most prompt level
**  The file saveload.tex in the dev directory describes the saved format
**  in more detail. Most of the work will be done from inside GASMAN, because
**  we need to fiddle with Bag internals somewhat
**
**  The return value is either True or Fail
*/

static Obj IsWritableFile;

Obj SaveWorkspace( Obj fname )
{
  Obj fileok;
  fileok = CALL_1ARGS(IsWritableFile, fname);
  if (fileok == True)
    return False;
  else if (fileok == False)
    return Fail;
  else
    ErrorQuit("Panic: invalid return from IsWritable",0L,0L);
  return 0; /* please lint */
}

/***************************************************************************
**
*F  LoadWorkspace( <fname> ) . . . . . .load the workspace to the named file
**
**  'LoadWorkspace' is the entry point to the workspace saving. It is not
**  installed as a GAP function, but instead as a keyword, so that we can be
**  sure it is only being called from the top-most prompt level
**  The file saveload.tex in the dev directory describes the saved format
**  in more detail. Most of the work will be done from inside GASMAN, because
**  we need to fiddle with Bag internals somewhat
**
**  It may return Fail, in the original workspace, True, in the new workspace
**  or abort the system if an error arises too late to be safely averted
*/

static Obj IsReadableFile;

Obj LoadWorkspace( Obj fname )
{
  Obj fileok;
  fileok = CALL_1ARGS(IsReadableFile, fname);
  if (fileok == True)
    return False;
  else if (fileok == False)
    return Fail;
  else
    ErrorQuit("Panic: invalid return from IsReadable",0L,0L);
  return 0; /* please lint */
}

/***************************************************************************
**
*F  InitSaveLoad( void ) . . . . . . . . . . . . . .initialize this package
*/

void InitSaveLoad( void )
{
  UInt tmp;
  tmp = GVarName("IsWritableFile");
  InitFopyGVar( tmp, &IsWritableFile );
  tmp = GVarName("IsReadableFile");
  InitFopyGVar( tmp, &IsReadableFile );
}
	       







