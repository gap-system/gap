/****************************************************************************
**
*W  cyclotom.h                  GAP source                   Martin Schönert
**
*H  @(#)$Id: cyclotom.h,v 4.8 2010/02/23 15:13:41 gap Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file implements the arithmetic for elements from  cyclotomic  fields
**  $Q(e^{{2 \pi i}/n}) = Q(e_n)$,  which  we  call  cyclotomics  for  short.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_cyclotom_h =
   "@(#)$Id: cyclotom.h,v 4.8 2010/02/23 15:13:41 gap Exp $";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoCyc() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoCyc ( void );


/****************************************************************************
**

*E  cyclotom.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


