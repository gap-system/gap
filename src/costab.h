/****************************************************************************
**
*W  costab.h                    GAP source                       Frank Celler
*W                                                           & Volkmar Felsch
*W                                                         & Martin Schönert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions for coset tables.
*/

#ifndef GAP_COSTAB_H
#define GAP_COSTAB_H

#ifdef INCLUDE_DECLARATION_PART
const char * Revision_costab_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoCosetTable() . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoCosetTable ( void );



#endif // GAP_COSTAB_H

/****************************************************************************
**

*E  costab.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
