/****************************************************************************
**
*W  compstat.c                  GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*/
#include        "system.h"
#include        "compstat.h"


/****************************************************************************
**

*V  CompInitFuncs . . . . . . . . . .  list of compiled module init functions
**
**  This a dummy list in case no module statically linked.
*/
#ifdef USE_PRECOMPILED
extern StructCompInitInfo * Init_lib_methsel_g ( void );
extern StructCompInitInfo * Init_lib_type_g ( void );
#endif

CompInitFunc CompInitFuncs [] = {
#ifdef USE_PRECOMPILED
    Init_lib_methsel_g,
    Init_lib_type_g,
#endif
    0
};


/****************************************************************************
**

*E  compstat.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
