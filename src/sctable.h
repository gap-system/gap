/****************************************************************************
**
*W  sctable.h                   GAP source                     Marcel Roelofs
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,        CWI,        Amsterdam,        The Netherlands
**
**  This file declares a fast access  function for structure constants tables
**  and the multiplication of two elements using a structure constants table.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_sctable_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  SetupSCTable()  . . . . . . . . . .  initialize structure constant tables
*/
extern void SetupSCTable ( void );


/****************************************************************************
**
*F  InitSCTable() . . . . . . . . . . .  initialize structure constant tables
**
**  Is called  during the initialization  of GAP to initialize  the structure
**  constant table package.
*/
extern void InitSCTable ( void );


/****************************************************************************
**
*F  CheckSCTable()  . . check the initialisation of structure constant tables
*/
extern void CheckSCTable ( void );


/****************************************************************************
**

*E  sctable.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



