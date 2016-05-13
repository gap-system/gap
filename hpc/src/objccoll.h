/****************************************************************************
**
*W  objccoll.h                  GAP source                      Werner Nickel
**
**
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
*/

#ifndef GAP_OBJCCOLL_H
#define GAP_OBJCCOLL_H

/****************************************************************************
**

*D  SCP_SOMETHING . . . . . . . . . . . . . . .  for combinatorial collectors
**
**  Definitions which are needed by the combinatorial collectors in addition
**  to those made for single collectors.
*/
#define SCP_WEIGHTS        SCP_LAST+1   /* weight in a combi collector     */
#define SCP_CLASS          SCP_LAST+2   /* p-class in a combi collector    */
#define SCP_AVECTOR2       SCP_LAST+3   /* avector                         */

/****************************************************************************
**

*D  SC_SOMETHING( <sc> )  . . . . . . . . . . .  for combinatorial collectors
**
*/
#define SC_CLASS(sc) \
    (ADDR_OBJ(sc)[SCP_CLASS])

#define SC_WEIGHTS(sc) \
    (ADDR_OBJ(sc)[SCP_WEIGHTS])

#define SC_AVECTOR2(sc) \
    (ADDR_OBJ(sc)[SCP_AVECTOR2])


/****************************************************************************
**
**  Here we declare the combinatorial collector  functions.  Pointer to those
**  functions  are  put into  the   relevant  data structures in  the  single
**  collector module.   Therefore,  the  single  collector  module needs   to
**  include this file.
*/
Int C8Bits_CombiCollectWord ( Obj, Obj, Obj );
Int C16Bits_CombiCollectWord ( Obj, Obj, Obj );
Int C32Bits_CombiCollectWord ( Obj, Obj, Obj );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoCombiCollector()  . . . . . . . . . . . . table of init functions
*/

StructInitInfo * InitInfoCombiCollector ( void );


#endif // GAP_OBJCCOLL_H

/****************************************************************************
**

*E  objccoll.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
