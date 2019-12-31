/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_COLLECTORS_H
#define GAP_COLLECTORS_H

#include "common.h"

/****************************************************************************
**
*D  SCP_SOMETHING
**
*/
#define SCP_UNDERLYING_FAMILY       1   /* the family of our free grp elms */
#define SCP_RWS_GENERATORS          2   /* the free grp generators used    */
#define SCP_NUMBER_RWS_GENERATORS   3   /* number of generators            */
#define SCP_DEFAULT_TYPE            4   /* default type of the result      */
#define SCP_IS_DEFAULT_TYPE         5   /* tester for default type         */
#define SCP_RELATIVE_ORDERS         6   /* list of relative orders         */
#define SCP_POWERS                  7   /* list of power rhs               */
#define SCP_CONJUGATES              8   /* list of list of conjugates rhs  */
#define SCP_INVERSES                9   /* list of inverses of the gens    */
#define SCP_COLLECTOR              10   /* collector to use                */
#define SCP_AVECTOR                11   /* avector                         */
#define SCP_LAST          SCP_AVECTOR   /* last entry in a single coll.    */


/****************************************************************************
**
*D  SC_SOMETHING( <sc> )
**
**  WARNING: 'cwVector' and 'cw2Vector' must be cleaned after using them.
*/
#define SC_AVECTOR(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_AVECTOR])

#define SC_COLLECTOR(sc) \
    (FinPowConjCollectors[INT_INTOBJ(CONST_ADDR_OBJ(sc)[SCP_COLLECTOR])])

#define SC_CONJUGATES(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_CONJUGATES])

#define SC_DEFAULT_TYPE(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_DEFAULT_TYPE])

#define SC_INVERSES(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_INVERSES])

#define SC_NUMBER_RWS_GENERATORS(sc) \
    (INT_INTOBJ((CONST_ADDR_OBJ(sc)[SCP_NUMBER_RWS_GENERATORS])))

#define SC_POWERS(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_POWERS])

#define SC_RELATIVE_ORDERS(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_RELATIVE_ORDERS])

#define SC_RWS_GENERATORS(sc) \
    (CONST_ADDR_OBJ(sc)[SCP_RWS_GENERATORS])


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoCollectors() . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoCollectors ( void );


#endif // GAP_COLLECTORS_H
