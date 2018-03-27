/****************************************************************************
**
*W  compstat.c                  GAP source                       Frank Celler
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
*/

#include <src/system.h>
#include <src/compstat.h>

// #define AVOID_PRECOMPILED


/****************************************************************************
**
*V  CompInitFuncs . . . . . . . . . .  list of compiled module init functions
**
**  This a dummy list in case no module is statically linked.
*/
#ifndef AVOID_PRECOMPILED
extern StructInitInfo * Init__type1 ( void );
extern StructInitInfo * Init__oper1( void );
#endif

InitInfoFunc CompInitFuncs [] = {
#ifndef AVOID_PRECOMPILED
    Init__type1,
    Init__oper1,
#endif
    0
};
