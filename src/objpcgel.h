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

#include "common.h"
#include "objfgelm.h"


// PCWP is a subrep of AWP
/****************************************************************************
**
*D  PCWP_SOMETHING
**
**  The following enum constants are positions of non-defining data in the
**  types of pc words (PCWP = PC Word Position). Such words are a special
**  case of associative words, so we make sure the positions defined here
**  follow after the AWP_* positions.
*/
enum {
    START_ENUM_RANGE_INIT(PCWP_FIRST_ENTRY, AWP_LAST_ENTRY + 1),

        // list of names
        PCWP_NAMES,

        // collector to use
        PCWP_COLLECTOR,

    END_ENUM_RANGE(PCWP_LAST_ENTRY),
};

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
