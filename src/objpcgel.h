/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_OBJPCGEL_H
#define GAP_OBJPCGEL_H

#include "system.h"
#include "objfgelm.h"

/****************************************************************************
**
*V  PCWP_FIRST_ENTRY  . . . . . . . . . . . . . . first entry in subrep of AW
*/
#define PCWP_FIRST_ENTRY        AWP_FIRST_FREE


/****************************************************************************
**
*V  PCWP_NAMES  . . . . . . . . . . . . . . . . . . . . . . . . list of names
*/
#define PCWP_NAMES              (PCWP_FIRST_ENTRY+1)


/****************************************************************************
**
*V  PCWP_COLLECTOR  . . . . . . . . . . . . . . . . . . . .  collector to use
*/
#define PCWP_COLLECTOR          (PCWP_FIRST_ENTRY+2)


/****************************************************************************
**
*V  PCWP_FIRST_FREE . . . . . . . . . . . . .  first free position for subrep
*/
#define PCWP_FIRST_FREE         (PCWP_FIRST_ENTRY+3)


/****************************************************************************
**
*F  COLLECTOR_PCWORD( <obj> ) . . . . . . . . . . . . . .  collector of <obj>
*/
#define COLLECTOR_PCWORD(obj) \
    ( ELM_PLIST( TYPE_DATOBJ(obj), PCWP_COLLECTOR ) )


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoPcElements()  . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPcElements ( void );


#endif // GAP_OBJPCGEL_H
