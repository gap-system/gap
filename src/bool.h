/****************************************************************************
**
*W  bool.h                      GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions for the boolean package.
*/

#ifndef GAP_BOOL_H
#define GAP_BOOL_H


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
*V  SFail  . . . . . . . . . . . . . . . . . . . . . . . . . . superfail value
**
**  'SFail' is an ``superfail'' object which is used to indicate failure if
**  `fail' itself is a sensible response. This is used when having GAP read
**  a file line-by-line via a library function (demo.g)
*/
extern Obj SFail;


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoBool()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoBool ( void );


#endif // GAP_BOOL_H

/****************************************************************************
**

*E  bool.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
