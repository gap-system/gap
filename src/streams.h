/****************************************************************************
**
*W  streams.h                   GAP source                       Frank Celler
*W                                                  & Burkhard Höfling (MAC)
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the  various read-eval-print loops and streams related
**  stuff.  The system depend part is in "sysfiles.c".
*/

#ifndef GAP_STREAMS_H
#define GAP_STREAMS_H


/****************************************************************************
**

*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/


/****************************************************************************
**
*F  READ()  . . . . . . . . . . . . . . . . . . . . . . .  read current input
**
**  Read the current input and close the input stream.
*/
extern Int READ ( void );

/****************************************************************************
**
*F  READ()  . . . . . . . . . . . . . . . . . . . . . . .  read current input
**
**  Read the current input and close the input stream. Disable the normal 
** mechanism which ensures that quitting from a break loop gets you back to a 
** live prompt. This is initially designed for the files read from the command 
** line
*/
extern Int READ_NORECOVERY ( void );


/****************************************************************************
**
*F  READ_AS_FUNC()  . . . . . . . . . . . . .  read current input as function
**
**  Read the current input as function and close the input stream.
*/
extern Obj READ_AS_FUNC ( void );


/****************************************************************************
**
*F  READ_TEST() . . . . . . . . . . . . . . . . .  read current input as test
**
**  Read the current input as test and close the input stream.
*/
extern Int READ_TEST ( void );


/****************************************************************************
**
*F  READ_GAP_ROOT( <filename> ) . . .  read from gap root, dyn-load or static
**
**  'READ_GAP_ROOT' tries to find  a file under  the root directory,  it will
**  search all   directories given   in 'SyGapRootPaths',  check  dynamically
**  loadable modules and statically linked modules.
*/
extern Int READ_GAP_ROOT ( Char * filename );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoStreams() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoStreams ( void );


#endif // GAP_STREAMS_H

/****************************************************************************
**

*E  streams.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
