/****************************************************************************
**
*W  cyclotom.h                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file implements the arithmetic for elements from  cyclotomic  fields
**  $Q(e^{{2 \pi i}/n}) = Q(e_n)$,  which  we  call  cyclotomics  for  short.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_cyclotom_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupCyc()  . . . . . . . . . . . . . . initialize the cyclotomic package
*/
extern void SetupCyc ( void );


/****************************************************************************
**
*F  InitCyc() . . . . . . . . . . . . . . . initialize the cyclotomic package
**
**  'InitCyc' initializes the cyclotomic package.
*/
extern void InitCyc ( void );



/****************************************************************************
**
*F  CheckCyc()  . . . . .  check the initialisation of the cyclotomic package
**
**  'InitCyc' initializes the cyclotomic package.
*/
extern void CheckCyc ( void );


/****************************************************************************
**

*E  cyclotom.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


