/****************************************************************************
**
*W  bool.h                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions for the boolean package.
*/
#ifdef INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_bool_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*V  True  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  true value
**
**   'True' is the value 'true'.
*/
extern Obj True;


/****************************************************************************
**
*V  False . . . . . . . . . . . . . . . . . . . . . . . . . . . . false value
**
**  'False' is the value 'false'.
*/
extern Obj False;


/****************************************************************************
**
*V  Fail  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  fail value
**
**  'Fail' is the value 'fail'.
*/
extern Obj Fail;


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*E  SetupBool() . . . . . . . . . . . . . . . initialize the booleans package
*/
extern void SetupBool ( void );


/****************************************************************************
**
*E  InitBool()  . . . . . . . . . . . . . . . initialize the booleans package
**
**  'InitBool' initializes the boolean package.
*/
extern void InitBool ( void );


/****************************************************************************
**
*E  CheckBool() . check the initialisation of initialize the booleans package
**
**  'InitBool' initializes the boolean package.
*/
extern void CheckBool ( void );


/****************************************************************************
**

*E  bool.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/




