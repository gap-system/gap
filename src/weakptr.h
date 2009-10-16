/****************************************************************************
**
*W  weakptr.h                   GAP source                       Steve Linton
**
*H  @(#)$Id: weakptr.h,v 4.6 2002/04/15 10:04:03 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions that deal with weak pointer objects
**       it has to interwork somewhat closely with GASMAN.
**
**  A  weak pointer looks like a plain list, except that it does not cause
**  its entries to remain alive through a garbage collection, with the consequent
**  side effect, that its entries may vanish at any time.
**
**
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_weakptr_h =
   "@(#)$Id: weakptr.h,v 4.6 2002/04/15 10:04:03 sal Exp $";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoWeakPtr() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoWeakPtr ( void );


/****************************************************************************
**

*E  weakptr.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
