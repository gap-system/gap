/****************************************************************************
**
*W  bool.h                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file declares the functions for the boolean package.
*/
#ifdef INCLUDE_DECLARATION_PART
const char * Revision_bool_h =
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

*F  InitInfoBool()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoBool ( void );


/****************************************************************************
**

*E  bool.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/




