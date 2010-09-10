/****************************************************************************
**
*W  macfloat.h                      GAP source                  Steve Linton
**
*H  @(#)$Id: macfloat.h,v 4.2 2010/02/23 15:13:44 gap Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions for the macfloating point package
*/
#ifdef INCLUDE_DECLARATION_PART
const char * Revision_macfloat_h =
   "@(#)$Id: macfloat.h,v 4.2 2010/02/23 15:13:44 gap Exp $";
#endif


typedef double Double;


/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * **/

/****************************************************************************
**

*F  InitInfoMacfloat()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoMacfloat ( void );


/****************************************************************************
**
*E  macfloat.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/




