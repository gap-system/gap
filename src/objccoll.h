/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_OBJCCOLL_H
#define GAP_OBJCCOLL_H

#include "common.h"

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
    (CONST_ADDR_OBJ(sc)[SCP_CLASS])

#define SC_WEIGHTS(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_WEIGHTS])

#define SC_AVECTOR2(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_AVECTOR2])


/****************************************************************************
**
**  Here we declare the combinatorial collector  functions.  Pointer to those
**  functions  are  put into  the   relevant  data structures in  the  single
**  collector module.   Therefore,  the  single  collector  module needs   to
**  include this file.
*/
Int C8Bits_CombiCollectWord(Obj, Obj, Obj);
Int C16Bits_CombiCollectWord(Obj, Obj, Obj);
Int C32Bits_CombiCollectWord(Obj, Obj, Obj);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoCombiCollector()  . . . . . . . . . . . . table of init functions
*/

StructInitInfo * InitInfoCombiCollector ( void );


#endif // GAP_OBJCCOLL_H
