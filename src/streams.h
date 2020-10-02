/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the  various read-eval-print loops and streams related
**  stuff.  The system depend part is in "sysfiles.c".
*/

#ifndef GAP_STREAMS_H
#define GAP_STREAMS_H

#include "common.h"

/****************************************************************************
**
*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/


/****************************************************************************
**
*F  READ_AS_FUNC()  . . . . . . . . . . . . .  read current input as function
**
**  Read the current input as function. The caller is responsible for opening
**  and closing the input.
*/
Obj READ_AS_FUNC(TypInputFile * input);


/****************************************************************************
**
*F  READ_GAP_ROOT( <filename> ) . . .  read from gap root, dyn-load or static
**
**  'READ_GAP_ROOT' tries to find  a file under  the root directory,  it will
**  search all   directories given   in 'SyGapRootPaths',  check  dynamically
**  loadable modules and statically linked modules.
*/
Int READ_GAP_ROOT(const Char * filename);

// READ_ALL_COMMANDS reads a string of GAP statements and executes them
// allowing to capture and process outputs
extern Obj
READ_ALL_COMMANDS(Obj instream, Obj echo, Obj capture, Obj resultCallback);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoStreams() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoStreams ( void );


#endif // GAP_STREAMS_H
