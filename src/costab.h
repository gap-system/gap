/****************************************************************************
**
*W  costab.h                    GAP source                       Frank Celler
*W                                                           & Volkmar Felsch
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions for coset tables.
*/
#ifdef INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_costab_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  SetupCosetTable() . . . . . . . . . .  initialize the coset table package
*/
extern void SetupCosetTable ( void );


/****************************************************************************
**
*F  InitCosetTable()  . . . . . . . . . .  initialize the coset table package
*/
extern void InitCosetTable ( void );


/****************************************************************************
**
*F  CheckCosetTable() . . check the initialisation of the coset table package
*/
extern void CheckCosetTable ( void );


/****************************************************************************
**

*E  costab.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
