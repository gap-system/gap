/****************************************************************************
**
*W  objpcgel.h                  GAP source                       Frank Celler
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
*/

#ifndef GAP_OBJPCGEL_H
#define GAP_OBJPCGEL_H


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
*V  COLLECTOR_PCWORD( <obj> ) . . . . . . . . . . . . . .  collector of <obj>
*/
#define COLLECTOR_PCWORD(obj) \
    ( ELM_PLIST( TYPE_DATOBJ(obj), PCWP_COLLECTOR ) )


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoPcElements()  . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPcElements ( void );


#endif // GAP_OBJPCGEL_H

/****************************************************************************
**
*E  objpcgel.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
