/****************************************************************************
**
*W  compstat.c                  GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*/
#include        "system.h"
#include        "compstat.h"            /* statically linked modules       */


/****************************************************************************
**

*V  CompInitFuncs . . . . . . . . . .  list of compiled module init functions
**
**  This a dummy list in case no module is statically linked.
*/
#ifndef AVOID_PRECOMPILED
extern StructInitInfo * Init__methsel ( void );
extern StructInitInfo * Init__type ( void );
#endif

InitInfoFunc CompInitFuncs [] = {
#ifndef AVOID_PRECOMPILED
    Init__methsel,
    Init__type,
#endif
    0
};


/****************************************************************************
**

*E  compstat.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
