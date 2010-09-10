/****************************************************************************
**
*W  sctable.h                   GAP source                     Marcel Roelofs
**
*H  @(#)$Id: sctable.h,v 4.8 2010/02/23 15:13:48 gap Exp $
**
*Y  Copyright (C)  1996,        CWI,        Amsterdam,        The Netherlands
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares a fast access  function for structure constants tables
**  and the multiplication of two elements using a structure constants table.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_sctable_h =
   "@(#)$Id: sctable.h,v 4.8 2010/02/23 15:13:48 gap Exp $";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoSCTable() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoSCTable ( void );


/****************************************************************************
**

*E  sctable.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



