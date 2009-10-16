/****************************************************************************
**
*W  cyclotom.h                  GAP source                   Martin Schoenert
**
*H  @(#)$Id: cyclotom.h,v 4.7 2002/04/15 10:03:46 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file implements the arithmetic for elements from  cyclotomic  fields
**  $Q(e^{{2 \pi i}/n}) = Q(e_n)$,  which  we  call  cyclotomics  for  short.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_cyclotom_h =
   "@(#)$Id: cyclotom.h,v 4.7 2002/04/15 10:03:46 sal Exp $";
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


