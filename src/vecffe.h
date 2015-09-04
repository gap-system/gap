/****************************************************************************
**
*W  vecffe.h                    GAP source                      Werner Nickel
**
**
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
*/

#ifndef GAP_VECFFE_H
#define GAP_VECFFE_H


/* returns a sensible choice of q such that GF(q)
contains all the elements of vec. It will either be one already
stored, or the smallest one. */

extern UInt ChooseFieldVecFFE(Obj vec);

/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoVecFFE()  . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoVecFFE ( void );


#endif // GAP_VECFFE_H

/****************************************************************************
**

*E  vecffe.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
