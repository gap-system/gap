/****************************************************************************
**
*W  weakptr.h                   GAP source                       Steve Linton
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
SYS_CONST char * Revision_weakptr_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupWeakPtr( )  . . . . . . . . . .  initialize the weak pointer package
*/
extern void SetupWeakPtr ( void );


/****************************************************************************
**
*F  InitWeakPtr( ) . . . . . . . . . . .  initialize the weak pointer package
*/
extern void InitWeakPtr ( void );


/****************************************************************************
**
*F  CheckWeakPtr( )  . . check the initialisation of the weak pointer package
*/
extern void CheckWeakPtr ( void );


/****************************************************************************
**

*E  weakptr.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
