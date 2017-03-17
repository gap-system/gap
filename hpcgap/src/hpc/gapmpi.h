/****************************************************************************
**
*W  gapmpi.h            GAP source - ParGAP/MPI hooks          Gene Cooperman
**
*H  @(#)@(#)$Id: gapmpi.h,v 1.4 2001/07/12 15:08:52 gap Exp $
**
*Y  Copyright (C) 1999-2001  Gene Cooperman
*Y    See included file, COPYING, for conditions for copying
**
*/

/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

StructInitInfo * InitInfoPargapmpi ( void );
void InitPargapmpi (int * argc_ptr, char *** argv_ptr );

/* For backward compatibility */
StructInitInfo * InitInfoGapmpi ( void );
void InitGapmpi (int * argc_ptr, char *** argv_ptr );


/****************************************************************************
**

*E  gapmpi.h   . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
