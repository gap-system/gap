/****************************************************************************
**
*A  saveload.h                  GAP source                   Steve Linton
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions concerned with saving and loading
**  the workspace. There are support functions in gasman.c and elsewhere
**  throughout the kernel
*/
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_saveload_h =
   "@(#)$Id$";
#endif

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

extern Obj SaveWorkspace( Obj fname );

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

extern Obj LoadWorkspace( Obj fname );

/***************************************************************************
**
*F  InitSaveLoad( void ) . . . . . . . . . . . . . .initialize this package
*/

extern void InitSaveLoad( void );
