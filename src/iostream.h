/****************************************************************************
**
*W  iostream.h                      GAP source                  Steve Linton
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions for the floating point package
*/

#ifndef GAP_IOSTREAM_H
#define GAP_IOSTREAM_H

#include <src/system.h>

// Provide a feature macro to let libraries check if GAP supports
// CheckChildStatusChanged.
#define GAP_HasCheckChildStatusChanged

int CheckChildStatusChanged(int childPID, int status);

/*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoFloat()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoIOStream ( void );


#endif // GAP_IOSTREAM_H
